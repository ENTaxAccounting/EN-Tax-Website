const https = require('https');
const fs = require('fs');

const API_KEY = process.env.GOOGLE_PLACES_API_KEY;
const BUSINESS_NAME = 'E&N Tax and Accounting LLC';
const BUSINESS_PHONE = '+19144830713';
const DATA_FILE = 'reviews-data.json';

function httpsGet(url) {
  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try { resolve(JSON.parse(data)); }
        catch (e) { reject(new Error('Invalid JSON: ' + data.substring(0, 200))); }
      });
      res.on('error', reject);
    }).on('error', reject);
  });
}

function httpsPost(url, body, headers) {
  return new Promise((resolve, reject) => {
    const payload = JSON.stringify(body);
    const urlObj = new URL(url);
    const options = {
      hostname: urlObj.hostname,
      path: urlObj.pathname + urlObj.search,
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(payload), ...headers }
    };
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try { resolve(JSON.parse(data)); }
        catch (e) { reject(new Error('Invalid JSON: ' + data.substring(0, 200))); }
      });
    });
    req.on('error', reject);
    req.write(payload);
    req.end();
  });
}

async function findPlace() {
  // Attempt 1: phone number lookup with correct inputtype
  console.log('Trying phone number lookup...');
  const phoneUrl = `https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=${encodeURIComponent(BUSINESS_PHONE)}&inputtype=phonenumber&fields=place_id,name,rating,user_ratings_total&key=${API_KEY}`;
  const phoneData = await httpsGet(phoneUrl);
  if (phoneData.status === 'OK' && phoneData.candidates && phoneData.candidates.length) {
    const p = phoneData.candidates[0];
    console.log(`Found via phone: ${p.name} (${p.place_id})`);
    return p;
  }
  console.log(`Phone lookup: ${phoneData.status}`);

  // Attempt 2: new Places API v1 text search
  console.log('Trying Places API v1 text search...');
  const v1Data = await httpsPost(
    'https://places.googleapis.com/v1/places:searchText',
    { textQuery: BUSINESS_NAME },
    { 'X-Goog-Api-Key': API_KEY, 'X-Goog-FieldMask': 'places.id,places.displayName,places.rating,places.userRatingCount' }
  );
  if (v1Data.places && v1Data.places.length) {
    const p = v1Data.places[0];
    console.log(`Found via v1: ${p.displayName.text} (${p.id})`);
    return { place_id: p.id, name: p.displayName.text, rating: p.rating, user_ratings_total: p.userRatingCount };
  }
  console.log(`v1 search result: ${JSON.stringify(v1Data).substring(0, 200)}`);

  throw new Error('All lookup methods failed. Set place_id manually in reviews-data.json.');
}

async function getPlaceDetails(placeId) {
  const fields = 'reviews,rating,user_ratings_total';
  const url = `https://maps.googleapis.com/maps/api/place/details/json?place_id=${placeId}&fields=${fields}&reviews_sort=newest&key=${API_KEY}`;
  const data = await httpsGet(url);
  if (data.status !== 'OK') {
    throw new Error(`Place Details failed: ${data.status}`);
  }
  return data.result;
}

async function main() {
  if (!API_KEY) throw new Error('GOOGLE_PLACES_API_KEY is not set');

  let existing = { place_id: null, reviews: [] };
  if (fs.existsSync(DATA_FILE)) {
    existing = JSON.parse(fs.readFileSync(DATA_FILE, 'utf8'));
  }

  let place;
  if (existing.place_id) {
    console.log(`Using saved place_id: ${existing.place_id}`);
    place = { place_id: existing.place_id };
  } else {
    place = await findPlace();
  }

  const details = await getPlaceDetails(place.place_id);
  const freshReviews = details.reviews || [];
  console.log(`Got ${freshReviews.length} reviews from API`);

  const byAuthor = {};
  existing.reviews.forEach(r => {
    byAuthor[r.author_name.toLowerCase()] = r;
  });

  let added = 0;
  freshReviews.forEach(r => {
    const key = r.author_name.toLowerCase();
    if (byAuthor[key]) {
      Object.assign(byAuthor[key], r);
    } else {
      byAuthor[key] = r;
      added++;
    }
  });

  const merged = Object.values(byAuthor).sort((a, b) => (b.time || 0) - (a.time || 0));
  console.log(`${added} new review(s) added. Total: ${merged.length}`);

  const output = {
    place_id: place.place_id,
    business_name: BUSINESS_NAME,
    overall_rating: details.rating || place.rating,
    total_reviews: details.user_ratings_total || place.user_ratings_total,
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
