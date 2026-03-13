const https = require('https');
const fs = require('fs');

const { SERPAPI_KEY } = process.env;
const DATA_FILE = 'reviews-data.json';
const BUSINESS_NAME = 'E&N Tax and Accounting LLC';
const BUSINESS_QUERY = 'E&N Tax and Accounting LLC';

function httpsGet(url) {
  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try { resolve({ status: res.statusCode, body: JSON.parse(data) }); }
        catch (e) { reject(new Error('Invalid JSON: ' + data.substring(0, 300))); }
      });
    }).on('error', reject);
  });
}

async function findDataId() {
  const query = encodeURIComponent(BUSINESS_QUERY);
  const url = `https://serpapi.com/search.json?engine=google_maps&q=${query}&type=search&api_key=${SERPAPI_KEY}`;
  const res = await httpsGet(url);
  if (res.status !== 200) throw new Error(`Maps search failed (${res.status}): ${JSON.stringify(res.body)}`);

  const results = res.body.local_results;
  if (!results || !results.length) throw new Error('No results found for business — cannot determine data_id');

  const match = results.find(r => r.title && r.title.toLowerCase().includes('e&n tax')) || results[0];
  if (!match.data_id) throw new Error('No data_id in search result: ' + JSON.stringify(match));

  console.log(`Found business: "${match.title}" (data_id: ${match.data_id})`);
  return match.data_id;
}

async function fetchReviews(dataId) {
  const url = `https://serpapi.com/search.json?engine=google_maps_reviews&data_id=${encodeURIComponent(dataId)}&sort_by=newestFirst&api_key=${SERPAPI_KEY}`;
  const res = await httpsGet(url);
  if (res.status !== 200) throw new Error(`Reviews fetch failed (${res.status}): ${JSON.stringify(res.body)}`);
  return res.body;
}

function normalizeReview(r) {
  return {
    author_name: r.user?.name || 'Anonymous',
    profile_photo_url: r.user?.thumbnail || '',
    rating: r.rating || 5,
    text: r.snippet || '',
    time: r.iso_date ? Math.floor(new Date(r.iso_date).getTime() / 1000) : 0,
    relative_time_description: r.date || 'recently',
    review_id: r.user?.link || ''
  };
}

async function main() {
  if (!SERPAPI_KEY) throw new Error('Missing SERPAPI_KEY');

  let existing = { data_id: null, reviews: [] };
  if (fs.existsSync(DATA_FILE)) {
    existing = JSON.parse(fs.readFileSync(DATA_FILE, 'utf8'));
  }

  // Use cached data_id to avoid spending a search on discovery every run
  let dataId = existing.data_id;
  if (!dataId) {
    console.log('No cached data_id — searching for business on Google Maps...');
    dataId = await findDataId();
  } else {
    console.log(`Using cached data_id: ${dataId}`);
  }

  const reviewsData = await fetchReviews(dataId);
  const freshReviews = reviewsData.reviews || [];
  console.log(`Got ${freshReviews.length} review(s) from SerpApi`);

  // Merge: preserve manually-seeded entries, add/update from SerpApi
  const byAuthor = {};
  existing.reviews.forEach(r => {
    byAuthor[r.author_name.toLowerCase()] = r;
  });

  let added = 0;
  freshReviews.forEach(r => {
    const normalized = normalizeReview(r);
    if (byAuthor[normalized.author_name.toLowerCase()]) {
      Object.assign(byAuthor[normalized.author_name.toLowerCase()], normalized);
    } else {
      existing.reviews.push(normalized);
      byAuthor[normalized.author_name.toLowerCase()] = normalized;
      added++;
    }
  });

  const merged = existing.reviews.sort((a, b) => (b.time || 0) - (a.time || 0));
  console.log(`${added} new review(s) added. Total: ${merged.length}`);

  const placeInfo = reviewsData.place_info || {};
  const output = {
    data_id: dataId,
    business_name: BUSINESS_NAME,
    overall_rating: placeInfo.rating || existing.overall_rating || 5.0,
    total_reviews: placeInfo.reviews || existing.total_reviews || merged.length,
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
