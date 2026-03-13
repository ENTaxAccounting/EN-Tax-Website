const https = require('https');
const fs = require('fs');

const API_KEY = process.env.GOOGLE_PLACES_API_KEY;
const BUSINESS_NAME = 'E&N Tax and Accounting LLC';
const BUSINESS_PHONE = '(914) 483-0713';
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

async function findPlace() {
  const queries = [BUSINESS_NAME, 'E&N Tax Accounting', BUSINESS_PHONE];
  for (const query of queries) {
    const url = `https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=${encodeURIComponent(query)}&inputtype=textquery&fields=place_id,name,rating,user_ratings_total&key=${API_KEY}`;
    const data = await httpsGet(url);
    if (data.status === 'OK' && data.candidates && data.candidates.length) {
      const p = data.candidates[0];
      // Safety check: make sure we found E&N Tax, not a different business
      const nameMatch = p.name && (
        p.name.toLowerCase().includes('e&n') ||
        p.name.toLowerCase().includes('e and n') ||
        p.name.toLowerCase().includes('en tax')
      );
      if (!nameMatch) {
        console.log(`Query "${query}" matched wrong business: "${p.name}" — skipping`);
        continue;
      }
      console.log(`Found via "${query}": ${p.name} (${p.place_id})`);
      return p;
    }
    console.log(`Query "${query}" returned ${data.status}, trying next...`);
  }
  throw new Error('Could not find E&N Tax business in Google Places. Hardcode the place_id in reviews-data.json to bypass lookup.');
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

  // Use hardcoded place_id if available, otherwise look it up
  let place;
  if (existing.place_id) {
    console.log(`Using hardcoded place_id: ${existing.place_id}`);
    place = { place_id: existing.place_id };
  } else {
    place = await findPlace();
  }
  const details = await getPlaceDetails(place.place_id);
  const freshReviews = details.reviews || [];
  console.log(`Got ${freshReviews.length} reviews from API`);

  // Merge by author name — update existing entries, add new ones
  const byAuthor = {};
  existing.reviews.forEach(r => {
    byAuthor[r.author_name.toLowerCase()] = r;
  });

  let added = 0;
  freshReviews.forEach(r => {
    const key = r.author_name.toLowerCase();
    if (byAuthor[key]) {
      Object.assign(byAuthor[key], r); // refresh with latest API data
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
