# Repository Guidelines

## Project Structure & Module Organization

This repository is intentionally a dependency-free, five-page static website. Public source pages live at the repository root (`index.html`, `services.html`, `resources.html`, `reviews.html`, and `contact.html`), while Cloudflare Pages publishes only the generated `dist/` artifact. `public-files.json` is the deployment allowlist; `scripts/build-public.js` creates and verifies the artifact. The narrowly routed Pages Function in `functions/` returns true 404 responses for repository-only paths, including stale assets retained by Cloudflare. Shared presentation and behavior belong in `styles.css` and `main.js`; page-specific files use the page name, such as `contact.css` and `contact.js`. Images are under `images/`, with hero assets in `images/backgrounds/`. Review content is stored in `reviews-data.json` and synchronized by `fetch-reviews.js` through `.github/workflows/fetch-reviews.yml`. `_headers` defines production security headers and CSP rules.

The canonical production URLs are `https://www.entaxaccounting.com/`, `/services`, `/resources`, `/reviews`, and `/contact`. Root-level `.html` names are source filenames only. Use the extensionless URLs in internal links, canonicals, Open Graph metadata, structured data, sitemaps, and search-engine submissions; legacy `.html` requests should redirect to their extensionless equivalents.

Eleventy was considered and rejected while the site remains at five pages. Header and footer markup therefore remains duplicated by design; `scripts/check-public-artifact.js` enforces the shared navigation, footer, analytics, shared asset references, and organization schema contract during every build. Update global markup on all five pages together. This avoids a template dependency at the cost of manual synchronized edits, with the build check guarding against drift.

## Build, Test, and Development Commands

There is no dependency-install step. Build the approved public artifact and serve that directory:

```sh
node scripts/build-public.js
python3 -m http.server 8000 --directory dist
```

Then open `http://localhost:8000`. Re-run the artifact check with `node scripts/check-public-artifact.js`; this also verifies the five-page shared-layout contract. Check JavaScript syntax with `node --check main.js` (repeat for any changed `.js` file). Run `SERPAPI_KEY=... node fetch-reviews.js` only when intentionally refreshing reviews; it calls an external API and updates `reviews-data.json` when new reviews are found.

## Coding Style & Naming Conventions

Use four-space indentation in HTML, CSS, and browser JavaScript; follow the existing two-space style in `fetch-reviews.js`. Keep public filenames lowercase and use kebab-case for new assets. Put shared styles or behavior in the shared files and page-only changes in matching page files. Preserve the navy/gold CSS variables in `styles.css`. Inline scripts are prohibited by the CSP, so add behavior to external `.js` files. When changing navigation or footer markup, update every HTML page because there is no template system.

## Testing Guidelines

No automated test framework or coverage threshold is configured. Before submitting, serve the site locally and inspect every affected page at desktop and mobile widths. Verify navigation, hamburger behavior, links, forms, scroll effects, and browser-console errors. For review changes, confirm `reviews.html` loads and renders `reviews-data.json` correctly. Do not add self-serving `AggregateRating`, `reviewCount`, or `ratingValue` fields to the site's organization schema; the artifact check rejects them.

## Commit & Pull Request Guidelines

Recent commits use concise, imperative subjects such as `Fix hero carousel images` or `Update reviews data`. Keep each commit focused. Pull requests should summarize the user-visible change, list tested pages and viewport sizes, link any issue, and include before/after screenshots for visual work. Call out edits to `_headers`, analytics, forms, workflows, or secrets-related configuration. Never commit `.env` files, API keys, or local credentials.
