# Owner Setup Guide: WP-O1 Through WP-O4

This is the step-by-step companion to `production-roadmap.md`. The character after `WP-` is the letter **O** for **Owner**, not zero. These tasks happen mostly in external dashboards, so you can do them while Codex works on the development packages.

## Before You Start

Estimated owner time:

- `WP-O1`: 30–60 minutes
- `WP-O2`: 60–90 minutes, plus indexing wait time
- `WP-O3`: 60–90 minutes
- `WP-O4`: 60–120 minutes, depending on FAQ detail

Use an offline note for answers and screenshots. Do not put passwords, API keys, verification tokens, private addresses, tax identifiers, or client information in this repository or a chat. Avoid editing repository files or pushing to `main` while a development package is active.

## WP-O1 — Domain and Cloudflare

Goal: make `https://www.entaxaccounting.com` the only public hostname, preserve AI-search access, and help search engines discover updates.

### A. Confirm the production domain

1. Sign in to the [Cloudflare dashboard](https://dash.cloudflare.com/).
2. Open **Workers & Pages**, select the E&N Pages project, and open **Custom domains**.
3. Confirm `www.entaxaccounting.com` is listed as **Active**. Do not remove either custom domain during this work.
4. Approve this preferred URL in your notes: `https://www.entaxaccounting.com`.

### B. Redirect the apex domain to `www`

1. Select the `entaxaccounting.com` website/zone in Cloudflare.
2. Open **DNS > Records**. Confirm the apex record (`entaxaccounting.com` or `@`) is proxied through Cloudflare—the cloud should be orange. Do not change its target.
3. Open **Rules > Overview**.
4. Choose **Create rule > Redirect Rule**.
5. Name it `Redirect apex to www`.
6. Choose a wildcard-pattern match and enter:

   - Request URL: `https://entaxaccounting.com/*`
   - Target URL: `https://www.entaxaccounting.com/${1}`
   - Status: `301`
   - Preserve query string: **On**

7. Save/deploy the rule. Cloudflare documents this exact root-to-`www` pattern in its [redirect example](https://developers.cloudflare.com/rules/url-forwarding/examples/redirect-root-to-www/).
8. Open **SSL/TLS > Edge Certificates** and confirm **Always Use HTTPS** is enabled. If it is already on, leave it unchanged.
9. Test in a private/incognito window:

   - `http://entaxaccounting.com/`
   - `https://entaxaccounting.com/services.html`
   - `https://entaxaccounting.com/resources.html?test=1`
   - `https://www.entaxaccounting.com/`

   The first three should finish on the same path/query at the `www` HTTPS hostname. The fourth should remain on `www`.

### C. Review crawler preferences

1. In the zone, open **Security > Settings** and filter for **Bot traffic**. If your dashboard has the older layout, use **Security > Bots**.
2. Find **Set your preference to block training in robots.txt** or **Instruct bot traffic with robots.txt**.
3. Recommended setting: **On**. This preserves the current preference to allow normal search/reference while asking known training crawlers such as `GPTBot` and `ClaudeBot` not to train on the site. Cloudflare explains how it merges these rules with an existing file in its [managed robots documentation](https://developers.cloudflare.com/bots/additional-configurations/managed-robots-txt/).
4. Do not enable a broad rule that blocks every AI crawler. `OAI-SearchBot`, `Claude-SearchBot`, and `Claude-User` must remain accessible for the roadmap's AI-search goal.
5. After `WP-D1` is deployed, open `https://www.entaxaccounting.com/robots.txt`. Confirm it is plain text, contains a sitemap line, and contains no homepage HTML.

### D. Enable Crawler Hints

1. Open **Caching > Configuration** for the zone.
2. Find **Crawler Hints** and turn it on.
3. No IndexNow key is required. Cloudflare uses cache signals to notify participating search engines; the feature is available on all plans. See [Cloudflare Crawler Hints](https://developers.cloudflare.com/cache/advanced-configuration/crawler-hints/).

### WP-O1 completion record

Copy this into your offline note:

```text
WP-O1 COMPLETE
Preferred hostname: https://www.entaxaccounting.com
www custom domain active: yes/no
Apex-to-www 301 enabled: yes/no
Paths and query strings preserved: yes/no
Always Use HTTPS enabled: yes/no
Managed robots training preference enabled: yes/no
Broad AI crawler blocking disabled: yes/no
Crawler Hints enabled: yes/no
Problems or unexpected results:
```

## WP-O2 — Google and Bing Search Accounts

Goal: verify ownership, submit the sitemap, see why pages are or are not indexed, and request fresh indexing after `WP-D1`.

### A. Create a Google Search Console Domain property

1. Sign in to [Google Search Console](https://search.google.com/search-console/) with the long-term business-owned Google account.
2. Open the property selector and choose **Add property**.
3. Choose **Domain**, enter only `entaxaccounting.com`, and select **Continue**. Do not enter `https://`, `www`, or a path. A Domain property includes all protocols and subdomains.
4. Google will provide a TXT value beginning with `google-site-verification=`. Keep the Search Console dialog open.
5. In Cloudflare, open the `entaxaccounting.com` zone, then **DNS > Records > Add record**.
6. Enter:

   - Type: `TXT`
   - Name: `@`
   - Content: the exact Google verification value
   - TTL: `Auto`

7. Save the record, return to Search Console, and click **Verify**. DNS can take time; if verification fails, wait and retry rather than adding duplicate records.
8. Leave the TXT record in DNS permanently. Google's [ownership instructions](https://support.google.com/webmasters/answer/9008080?hl=en) warn that removing it can remove verification.

### B. Submit the sitemap

1. Confirm this URL opens in a logged-out browser: `https://www.entaxaccounting.com/sitemap.xml`.
2. In Search Console, select the `entaxaccounting.com` Domain property.
3. Open **Indexing > Sitemaps**.
4. Under **Add a new sitemap**, enter `https://www.entaxaccounting.com/sitemap.xml` (or enter `sitemap.xml` if the hostname is prefilled).
5. Select **Submit** and record the result. The target status is **Success**. Google explains the report and status meanings in its [Sitemaps documentation](https://support.google.com/webmasters/answer/7451001?hl=en).

### C. Inspect current pages

Wait until `WP-D1` is deployed, then use the exact canonical URLs listed in its completion report—do not guess whether `.html` or extensionless URLs were chosen.

For each canonical URL:

1. Paste the full URL into the inspection bar at the top of Search Console.
2. Record **URL is on Google** or **URL is not on Google**.
3. Expand **Page indexing** and record:

   - Last crawl
   - Page fetch status
   - User-declared canonical
   - Google-selected canonical
   - Any indexing reason or error

4. Select **Test live URL**.
5. If the live test succeeds and the page is new or changed, select **Request indexing**. Do this for the homepage first, followed by the other canonical pages. Requests are limited, so submit each URL once rather than repeatedly.
6. Search Console's [URL Inspection documentation](https://support.google.com/webmasters/answer/9012289?hl=en) explains that a successful live test shows accessibility, not guaranteed indexing.

Also review and record:

- **Indexing > Pages**
- **Experience > Core Web Vitals**
- **Security & Manual Actions > Manual actions**
- **Security & Manual Actions > Security issues**

### D. Set up Bing Webmaster Tools

1. Open [Bing Webmaster Tools](https://www.bing.com/webmasters/) and sign in with a durable business account.
2. Choose **Import sites from Google Search Console**.
3. Authorize read access, select `entaxaccounting.com`, and complete the import. Bing supports Search Console import as a verification shortcut. If import is unavailable, choose **Add site** and follow Bing's DNS verification instructions.
4. Select the imported site, open **Sitemaps**, and confirm `https://www.entaxaccounting.com/sitemap.xml` appears. If not, choose **Submit sitemap** and add it. See [Bing's sitemap guidance](https://www4.bing.com/webmasters/help/sitemaps-3b5cf6ed).
5. Open Bing's **URL Inspection** tool and inspect the same canonical URLs after `WP-D1`.
6. Record crawl/index errors; do not change site code yourself. Paste the results into the next relevant development chat.

### WP-O2 completion record

```text
WP-O2 STATUS
Search Console Domain property verified: yes/no
Verification TXT retained: yes/no
Google sitemap status:
Google indexed canonical URLs:
Google canonical conflicts/errors:
Manual actions: none/details
Security issues: none/details
Core Web Vitals status:
Bing site imported/verified: yes/no
Bing sitemap status:
Bing URL errors:
Date checked:
```

## WP-O3 — Verified Business Fact Sheet

Goal: give `WP-D2` accurate public information without exposing private or unsupported facts.

Status: completed and owner-approved on July 14, 2026. Use the repository-only `verified-business-facts.md` as the source of truth for `WP-D2` and later packages.

Create an offline document and fill in the following. Use `Not public` or `Needs confirmation` instead of guessing.

```text
WP-O3 VERIFIED BUSINESS FACT SHEET

IDENTITY
Public brand name:
Legal business name:
Founding year:
Founder public name:
Founder approved title:

PUBLIC CONTACT
Public email:
Public phone (or "Not public"):
Public service-area city/region:
States/regions actually supported:
Can the site accurately say "nationwide"? Explain:

EXPERTISE — PUBLIC AND VERIFIABLE ONLY
Education:
Tax/accounting experience:
Licenses or credentials:
Professional affiliations:
Languages offered to clients:
Approved short biography facts:

SERVICES
Individual tax preparation — included/excluded:
Business tax preparation — included/excluded:
Bookkeeping — included/excluded:
Quarterly estimated taxes — included/excluded:
Tax consulting — included/excluded:
Client/revenue/complexity limits:
Pricing language approved for publication:
Typical response time:
Basic onboarding steps:

VERIFIED PUBLIC PROFILES
Google Business Profile URL:
LinkedIn URL:
Facebook URL:
Other official profile URLs:

DO NOT PUBLISH
List facts supplied for context but not approved for the website:
```

Before handing this off:

1. Ask Marija to verify every public claim.
2. Remove home addresses, personal phone numbers, account identifiers, and anything not approved for publication.
3. Do not describe Marija as a CPA, EA, attorney, or holder of another credential unless that credential is current and verified.
4. Paste only the publishable portion into the `WP-D2` chat.

## WP-O4 — Architecture and Content Priorities

Goal: make the decisions needed before the site expands from five pages to a larger service/resource site.

### A. Decide on Eleventy

Recommendation: approve the lightweight Eleventy migration.

What changes:

- Shared navigation, footer, metadata, and schema move into reusable templates.
- Cloudflare builds static HTML during deployment.
- Public pages remain fast and crawlable.
- Adding a page no longer requires copying the same header/footer into every file.

Tradeoff: the repository gains Node dependencies and a build command. Codex will implement and test this in `WP-D4`; you should **not** change Cloudflare build settings now. After implementation, the expected Cloudflare values are production branch `main`, build command `npx @11ty/eleventy`, and output directory `_site`, matching [Cloudflare's Eleventy guide](https://developers.cloudflare.com/pages/framework-guides/deploy-an-eleventy-site/).

Record one decision:

```text
Eleventy migration: APPROVED / REJECTED / NEEDS DISCUSSION
Reason or concern:
```

### B. Approve the navigation

Recommended top-level navigation:

```text
Home | About | Services | Resources | Reviews | Contact
```

Record changes you want. Keep service detail pages linked from the Services hub rather than placing all five in the top navigation.

### C. Rank the services

Assign each service a unique rank from 1 (highest business priority) to 5:

```text
Individual Tax Preparation:
Business Tax Preparation:
Bookkeeping:
Quarterly Estimated Taxes:
Tax Consulting:
```

Base the ranking on the clients E&N most wants, profitability, capacity, and expertise—not search volume alone.

### D. Write genuine FAQs

Start with the top two ranked services. Supply 3–5 questions per service in Marija's own words. Useful prompts include:

- Who is this service best suited for?
- What documents should a new client prepare?
- What is included and explicitly not included?
- How does virtual service work?
- What commonly causes delays?
- When during the year should someone contact E&N?
- How is pricing determined without promising a specific fee?

Answers can be rough bullet points. Accuracy and first-hand expertise matter more than polished marketing language; Codex can edit them later.

### E. Describe the client process

Fill in the real process without inventing tools or guarantees:

```text
1. How a prospect first contacts E&N:
2. What happens during the initial consultation:
3. How fit, scope, and pricing are confirmed:
4. How documents are exchanged securely:
5. How work and questions are handled:
6. How completion/delivery works:
7. What year-round follow-up is available:
```

### WP-O4 completion record

```text
WP-O4 COMPLETE
Eleventy decision:
Approved navigation:
Service ranking:
FAQs prepared for:
Client process documented: yes/no
Open questions or concerns:
```

## Handoff to a Development Chat

When an owner package is finished, paste its completion record and only the publishable inputs into the relevant development chat. Use this short introduction:

```text
I completed WP-O__. Below are the verified results. Treat anything marked "Needs confirmation" as unavailable and do not infer or publish it. Do not expose private details. Use these inputs only where the current development work package requires them.
```

If a dashboard label differs from this guide, stop before making an irreversible change, take a screenshot with private identifiers hidden, and ask for help. Cloudflare and search dashboard layouts change over time, but the settings and outcomes above are the source of truth.
