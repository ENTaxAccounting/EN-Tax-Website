const https = require('https');
const fs = require('fs');

const { GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, GOOGLE_REFRESH_TOKEN } = process.env;
const DATA_FILE = 'reviews-data.json';

const STAR_RATING = { ONE: 1, TWO: 2, THREE: 3, FOUR: 4, FIVE: 5 };

function httpsRequest(options, body) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try { resolve({ status: res.statusCode, body: JSON.parse(data) }); }
        catch (e) { reject(new Error('Invalid JSON: ' + data.substring(0, 300))); }
      });
    });
    req.on('error', reject);
    if (body) req.write(body);
    req.end();
  });
}

async function getAccessToken() {
  const body = [
    `grant_type=refresh_token`,
    `refresh_token=${encodeURIComponent(GOOGLE_REFRESH_TOKEN)}`,
    `client_id=${encodeURIComponent(GOOGLE_CLIENT_ID)}`,
    `client_secret=${encodeURIComponent(GOOGLE_CLIENT_SECRET)}`
  ].join('&');

  const res = await httpsRequest({
    hostname: 'oauth2.googleapis.com',
    path: '/token',
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'Content-Length': Buffer.byteLength(body) }
  }, body);

  if (!res.body.access_token) throw new Error('Failed to get access token: ' + JSON.stringify(res.body));
  console.log('Access token obtained.');
  return res.body.access_token;
}

async function gbpGet(accessToken, path) {
  const res = await httpsRequest({
    hostname: 'mybusiness.googleapis.com',
    path,
    method: 'GET',
    headers: { Authorization: `Bearer ${accessToken}` }
  });
  if (res.status !== 200) throw new Error(`GBP API error ${res.status} at ${path}: ${JSON.stringify(res.body)}`);
  return res.body;
}

async function getAccountId(accessToken) {
  // Use legacy mybusiness.googleapis.com endpoint to avoid quota issues with mybusinessaccountmanagement
  const data = await httpsRequest({
    hostname: 'mybusiness.googleapis.com',
    path: '/v4/accounts',
    method: 'GET',
    headers: { Authorization: `Bearer ${accessToken}` }
  });
  if (data.status !== 200) throw new Error('Failed to get accounts: ' + JSON.stringify(data.body));
  const accounts = data.body.accounts;
  if (!accounts || !accounts.length) throw new Error('No accounts found');
  console.log(`Account: ${accounts[0].name}`);
  return accounts[0].name; // e.g. "accounts/123456789"
}

async function getLocationId(accessToken, accountId) {
  const data = await gbpGet(accessToken, `/v4/${accountId}/locations?pageSize=10`);
  const locations = data.locations;
  if (!locations || !locations.length) throw new Error('No locations found on this account');
  console.log(`Location: ${locations[0].locationName} (${locations[0].name})`);
  return locations[0].name; // e.g. "accounts/123/locations/456"
}

async function getReviews(accessToken, locationId) {
  const data = await gbpGet(accessToken, `/v4/${locationId}/reviews?pageSize=50&orderBy=updateTime%20desc`);
  return {
    reviews: data.reviews || [],
    totalCount: data.totalReviewCount || 0,
    averageRating: data.averageRating || 0
  };
}

function normalizeReview(r) {
  return {
    author_name: r.reviewer.displayName || 'Anonymous',
    profile_photo_url: r.reviewer.profilePhotoUrl || '',
    rating: STAR_RATING[r.starRating] || 5,
    text: r.comment || '',
    time: Math.floor(new Date(r.createTime).getTime() / 1000),
    review_id: r.reviewId
  };
}

async function main() {
  if (!GOOGLE_CLIENT_ID || !GOOGLE_CLIENT_SECRET || !GOOGLE_REFRESH_TOKEN) {
    throw new Error('Missing required env vars: GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, GOOGLE_REFRESH_TOKEN');
  }

  let existing = { place_id: null, reviews: [] };
  if (fs.existsSync(DATA_FILE)) {
    existing = JSON.parse(fs.readFileSync(DATA_FILE, 'utf8'));
  }

  const accessToken = await getAccessToken();
  const accountId = await getAccountId(accessToken);
  const locationId = await getLocationId(accessToken, accountId);
  const { reviews: freshReviews, totalCount, averageRating } = await getReviews(accessToken, locationId);

  console.log(`Got ${freshReviews.length} reviews from GBP API`);

  // Merge by review_id (most reliable) or author name fallback for seeded entries
  const byId = {};
  const byAuthor = {};
  existing.reviews.forEach(r => {
    if (r.review_id) byId[r.review_id] = r;
    byAuthor[r.author_name.toLowerCase()] = r;
  });

  let added = 0;
  freshReviews.forEach(r => {
    const normalized = normalizeReview(r);
    if (byId[normalized.review_id]) {
      Object.assign(byId[normalized.review_id], normalized);
    } else if (byAuthor[normalized.author_name.toLowerCase()]) {
      Object.assign(byAuthor[normalized.author_name.toLowerCase()], normalized);
    } else {
      existing.reviews.push(normalized);
      added++;
    }
  });

  const merged = existing.reviews.sort((a, b) => (b.time || 0) - (a.time || 0));
  console.log(`${added} new review(s) added. Total: ${merged.length}`);

  const output = {
    place_id: existing.place_id,
    business_name: 'E&N Tax and Accounting LLC',
    overall_rating: averageRating,
    total_reviews: totalCount,
    last_fetched: new Date().toISOString(),
    reviews: merged
  };

  fs.writeFileSync(DATA_FILE, JSON.stringify(output, null, 2));
  console.log('Done.');
}

main().catch(err => {
  console.error(err.message);
  process.exit(1);
});
