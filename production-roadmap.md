# E&N Website Production Roadmap

Last updated: 2026-07-14

## Objective

Improve the site's crawlability, search visibility, AI-search eligibility, performance, information architecture, authority, and consultation conversion without sacrificing its simple Cloudflare Pages deployment. Work is divided into sequential development packages (`WP-D#`) and parallel owner packages (`WP-O#`).

## Working Rules

- Pushes to `main` deploy to production. Complete, verify, commit, and push only one development package per chat.
- The owner may work in parallel on external dashboards and an offline worksheet. Do not edit repository files on `main` while a development package is active.
- If owner repository edits are unavoidable, use a separate branch and tell the development chat before it begins.
- Preserve unrelated work. In particular, do not stage or modify `images/high-rez-original/` unless a work package explicitly requires it.
- Treat every file in the production artifact and every comment in shipped HTML, CSS, and JavaScript as public. Do not ship private notes, draft copy, commented-out features, dead code, credentials, or operational instructions; use Git history for removed code and a private tracker or offline note for internal lessons.
- Every completed development package must end with a scoped commit, a successful push, and the exact next-chat prompt. Do not create empty or partial commits when blocked.

## Responsibility Split

| Automated / Codex | Owner / Daniel and E&N | Joint decision or review |
|---|---|---|
| Repository audits, HTML/CSS/JS changes, metadata, schema, redirects supported by repo configuration, image optimization, accessibility, tests, documentation, commits, and pushes | Search Console, Bing Webmaster Tools, Cloudflare dashboard settings, business profiles, verified business facts, credentials, legal approval, account access, and final copy approval | Preferred hostname, crawler training policy, architecture migration, service priorities, public service area, conversion flow, and publishing calendar |

By implementation volume, roughly 75–85% can be handled by Codex. The remaining 15–25% requires account access, factual authority, or business judgment and should not be automated. Expect approximately 6–10 hours of owner setup/review across the initial roadmap, plus optional professional legal review and ongoing subject-matter review. Dashboard verification and content preparation can overlap most development sessions.

## Audit Findings and Planned Response

| Finding | Risk | Response |
|---|---|---|
| `www` and apex hostnames both serve content | Duplicate URL signals | `WP-D1` canonicals; `WP-O1` production redirect |
| No repository `robots.txt`; live response includes managed rules plus homepage HTML | Ambiguous crawler instructions | `WP-D1` clean crawler file; `WP-O1` Cloudflare review |
| Repository-only files and commented-out product copy are reachable in production | Internal process material, unpublished features, and unnecessary source are publicly exposed | `WP-D1A` explicit deployment artifact and source hygiene |
| Exact-name/domain search test favored third-party listings | Possible weak or incomplete indexing | `WP-O2` verification and URL inspection |
| Generic titles and incomplete social metadata | Weak relevance and sharing previews | `WP-D2` |
| Resources metadata/schema promises unavailable calculators | Trust and relevance mismatch | `WP-D2` |
| Repeated, inconsistent business schema lacks a stable entity ID | Weak entity clarity | `WP-D2`, using `WP-O3` facts |
| Five broad pages cover many distinct services and audiences | Insufficient search-intent depth | `WP-D5` through `WP-D7` are unlikely future expansion and require fresh owner approval before activation |
| Homepage audience images total about 13.5 MB before carousel assets | Slow loading and poor Core Web Vitals | `WP-D3` |
| Navigation and footer are duplicated across pages | Drift risk across manual edits | `WP-D4` shared-layout build validation while the site remains five static pages |
| Trust, privacy, and conversion details are limited | Reduced confidence and leads | `WP-D8` is unlikely future expansion and requires fresh owner approval before activation |

## Session Protocol

Every development chat must follow this protocol.

### 1. Preflight

1. Read `AGENTS.md` and this roadmap completely.
2. Run `git status --short`, `git branch --show-current`, and `git log -5 --oneline`.
3. Confirm the branch is `main`. Fetch `origin` and confirm local `main` is not behind. Do not pull across uncommitted overlapping work.
4. Treat all baseline changes as user-owned unless clearly created by a prior roadmap package. Stop only if they overlap the package.
5. Confirm all prerequisite owner decisions listed for the package. If a material decision is missing, report the blocker instead of guessing.
6. Treat the current deployment boundary as untrusted until `WP-D1A` passes. Check planned changes for private notes, draft copy, commented-out features, dead code, credentials, and repository-only files that could become public.
7. In Plan mode, show the implementation and verification plan and wait for approval before editing.

### 2. Execution

1. Implement only the named work package.
2. Preserve current brand voice, CSP restrictions, responsive behavior, and Formspree integration.
3. Keep shipped comments only when they provide concise, non-sensitive maintenance value. Delete obsolete or commented-out UI/copy instead of archiving it in public source.
4. Run package-specific tests plus `git diff --check`.
5. Review the full diff and verify that no unrelated file is staged and no internal-only material enters the production artifact.
6. Mark the package complete in this roadmap only after acceptance criteria pass.

### 3. Delivery

1. Stage only package files and the roadmap status update.
2. Commit with the package's listed commit subject.
3. Push to `origin/main` and verify the push succeeds. Because this deploys production, do not push a failing package.
4. Report files changed, tests run, commit hash, and push result.
5. End with the package's exact next-chat prompt. Do not begin the next package in the same chat.

## Parallel Owner Track

These tasks can run while development packages are underway because they occur outside the repository. Follow the detailed steps in `owner-work-packages.md`, keep the results in an offline note, and paste the relevant answers into the next development chat.

### WP-O1 — Domain and Cloudflare Decisions

Target: complete during `WP-D1`.

- Approve one public hostname. Recommendation: `https://www.entaxaccounting.com`, because current sitemap and social URLs use it.
- In Cloudflare, configure a permanent apex-to-`www` redirect and verify HTTP redirects to HTTPS.
- Review managed robots/content-signal settings. Current recommended policy: allow search/retrieval crawlers while continuing to block training crawlers if that matches E&N's preference.
- Confirm whether Cloudflare Crawler Hints is enabled.
- Record screenshots or exact settings and test results.

### [x] WP-O2 — Search Engine Accounts

Target: start immediately; complete before `WP-D9`.

Status: completed and owner-confirmed on July 16, 2026. Google Search Console and Bing Webmaster Tools are verified, both report the sitemap indexed, and all five extensionless canonical URLs are indexed without canonical conflicts, manual actions, security issues, or Bing URL errors. Core Web Vitals field status has not yet been confirmed and remains part of ongoing measurement.

- Verify a domain property in Google Search Console.
- Submit `/sitemap.xml`; inspect the homepage and four current page URLs.
- Record index status, selected canonical, crawl errors, manual actions, and Core Web Vitals.
- Set up Bing Webmaster Tools, preferably by importing Search Console, and submit the sitemap.
- After `WP-D1` deploys, request indexing for the canonical pages.

### [x] WP-O3 — Verified Business Fact Sheet

Target: complete before `WP-D2`.

Status: completed and owner-approved on July 14, 2026. The repository-only source of truth is `verified-business-facts.md`.

Provide only facts approved for public display:

- Legal and public business names, founding year, public email, and public phone if applicable.
- Service-area city/region and whether “nationwide” accurately describes supported work. Do not provide a private home address for publication.
- Marija's approved title, education, tax/accounting experience, credentials, professional affiliations, and languages.
- Exact services, client limits, pricing claims, response times, and onboarding steps.
- Verified Google Business Profile, LinkedIn, Facebook, or other official profile URLs.

### WP-O4 — Architecture and Content Priorities

Target: complete before `WP-D4`.

- Approve or reject a lightweight Eleventy migration. Recommendation: approve it before expanding beyond five pages so shared navigation, footer, metadata, and schema are generated consistently.
- Rank the five services by business priority.
- Approve a separate About page and the proposed navigation: Home, About, Services, Resources, Reviews, Contact.
- Supply 3–5 genuine FAQs for each priority service and a plain-language description of the client process.

### WP-O5 — Trust, Legal, and Conversion Inputs

Target: complete before `WP-D8`.

- Decide whether the primary action is “Request a Consultation” or a true calendar booking flow.
- Identify the approved scheduler and secure document portal, if any.
- Confirm what contact-form data is collected, retained, and shared.
- Review and approve privacy, terms, tax-information disclaimer, and accessibility drafts. Obtain professional legal review if desired; generated copy is not legal advice.

### WP-O6 — Off-Site Authority and Measurement

Target: begin after `WP-D2`; continue monthly.

- Make the business name, service area, hours, services, website, and description consistent across Google Business Profile, Bing Places, Apple Business Connect, and legitimate professional listings.
- Do not publish a private address or buy bulk directory links.
- Seek genuine mentions from chambers, professional organizations, partners, and community publications.
- Continue requesting authentic Google reviews without incentives.
- Record a monthly baseline: branded/non-branded impressions, indexed pages, Core Web Vitals, consultation submissions, and conversion rate.

## Development Track

### [x] WP-D1 — Crawl and Canonical Foundation

Dependencies: hostname choice from `WP-O1` is preferred; if unavailable, use `www` consistently and flag the dashboard redirect.

Implementation:

- Add a valid `robots.txt` with sitemap discovery and explicit allowance for `OAI-SearchBot`, `Claude-SearchBot`, and `Claude-User`.
- Preserve the current no-training preference for `GPTBot` and `ClaudeBot` unless the owner explicitly changes it.
- Add absolute self-referencing canonicals to all five pages.
- Make canonical, Open Graph, sitemap, and structured-data hostnames consistent.
- Verify `/index.html` behavior, crawler-file content, sitemap validity, and internal canonical targets locally and after deployment.

Acceptance: crawler file contains no HTML; all public pages have one valid canonical; no broken links or syntax errors; live smoke checks pass.

Commit: `Add crawl and canonical SEO controls`

Next prompt:

> Read `production-roadmap.md` and `AGENTS.md`, run the Session Protocol preflight, and if it passes, do WP-D1A in Plan mode. Show me the plan and wait for approval before implementing. Complete only WP-D1A, verify its acceptance criteria, commit, push, and end with the exact WP-D2 prompt from the roadmap.

### [x] WP-D1A — Public Deployment and Source Hygiene

Dependencies: `WP-D1`; confirmation of the Cloudflare Pages build command and output-directory settings from `WP-O1` before changing the deployment boundary.

Implementation:

- Inventory every file reachable on the production hostname and classify it as a public page/asset or repository-only material.
- Configure an explicit, reproducible public deployment artifact containing only approved pages, assets, crawler files, and required platform configuration; keep repository documentation, maintenance scripts, source data, credentials tooling, and development-only files out of it.
- Remove commented-out navigation, CTAs, service blocks, draft copy, and other dead code from shipped HTML, CSS, and JavaScript. Retain only concise implementation comments that are safe and useful to a public-source maintainer.
- Use Git history as the archive for removed code. Record non-sensitive lessons in a private owner note or private tracker, not in the production artifact; never preserve secrets or private client/business information in Git history.
- Add a repeatable deployment-artifact check that fails on unexpected files, commented-out elements/copy, credential patterns, or other internal-only material.
- Crawl the local artifact and production deployment, confirming all public routes/assets work and repository-only files return `404` rather than a soft-`200` homepage fallback.

Acceptance: production exposes only the approved public artifact; known repository-only paths return true `404` responses; no commented-out features, draft copy, credentials, or internal instructions remain in shipped source; site pages, forms, crawler files, CSP, and responsive behavior remain regression-free.

Commit: `Restrict production files and clean public source`

Next prompt:

> Read `production-roadmap.md` and `AGENTS.md`, run the Session Protocol preflight, and if it passes, do WP-D2 in Plan mode. Show me the plan and wait for approval before implementing. Complete only WP-D2, verify its acceptance criteria, commit, push, and end with the exact WP-D3 prompt from the roadmap.

### [x] WP-D2 — Metadata and Entity Schema

Dependencies: `WP-D1A`; verified facts from `WP-O3`.

Implementation:

- Write unique search-focused titles and descriptions that accurately match each page.
- Complete Open Graph and Twitter metadata, including canonical URLs and meaningful share images.
- Remove obsolete keyword metadata and correct Resources claims that are not visible on the page.
- Define one stable `AccountingService`/organization entity with `@id`, logo, founder, approved service area, contact data, and verified `sameAs` profiles.
- Reference that entity from page-specific `WebPage`, `Service`, breadcrumb, and FAQ data where appropriate.
- Remove or revise self-serving review markup that is not eligible for Google review snippets.
- Validate JSON-LD and social metadata.

Acceptance: every page has unique accurate metadata; schema parses without errors and matches visible facts; no private data is introduced.

Commit: `Improve metadata and structured data`

Next prompt:

> Read `production-roadmap.md` and `AGENTS.md`, run the Session Protocol preflight, and if it passes, do WP-D3 in Plan mode. Show me the plan and wait for approval before implementing. Complete only WP-D3, verify its acceptance criteria, commit, push, and end with the exact WP-D4 prompt from the roadmap.

### [x] WP-D3 — Performance and Accessibility Baseline

Dependencies: `WP-D2`.

Implementation:

- Measure current page weight and Lighthouse/PageSpeed baselines.
- Resize and convert production images to efficient formats while retaining originals outside the commit unless explicitly needed.
- Prevent unnecessary carousel and below-the-fold image loading; add dimensions, responsive sources, lazy loading, and priority hints where applicable.
- Add a skip link, robust focus states, reduced-motion support, accessible navigation labeling, and other high-confidence fixes found during audit.
- Test keyboard navigation, mobile layouts, console output, page weight, and Core Web Vitals proxies.

Acceptance: meaningful page-weight reduction with no visible regression; all current pages remain usable by keyboard and at mobile/desktop widths.

Commit: `Improve site performance and accessibility`

Next prompt:

> Read `production-roadmap.md` and `AGENTS.md`, run the Session Protocol preflight, and if it passes, do WP-D4 in Plan mode. Show me the plan and wait for approval before implementing. Complete only WP-D4, verify its acceptance criteria, commit, push, and end with the exact WP-D5 prompt from the roadmap.

### [x] WP-D4 — Shared Layout Architecture

Dependencies: `WP-D3`; architecture decision from `WP-O4`.

Decision: Eleventy rejected on July 15, 2026. The owner has not approved expanding beyond the existing five static pages.

Status: completed July 15, 2026 with the approved five-page shared-layout validation alternative.

Implementation:

- Keep the dependency-free five-page source architecture and the existing Cloudflare `dist/` build/output settings.
- Normalize the duplicated global footer markup and active navigation state across the five pages.
- Extend the public-artifact build check to enforce consistent navigation, footer, analytics, shared asset references, and entity schema.
- Remove the homepage slideshow pause control while retaining reduced-motion behavior.
- Document the maintenance tradeoff: global markup remains manually duplicated, while clean builds fail on detected drift.

Acceptance: production URLs and forms remain functional; generated pages match current content; clean builds are reproducible; CSP and security headers remain effective.

Commit: `Add shared static site architecture`

Next prompt:

> Read `production-roadmap.md` and `AGENTS.md`, run the Session Protocol preflight, and if it passes, do WP-D5 in Plan mode. Show me the plan and wait for approval before implementing. Complete only WP-D5, verify its acceptance criteria, commit, push, and end with the exact WP-D6 prompt from the roadmap.

### [ ] WP-D5 — Information Architecture and Trustworthy About Page

Status: unlikely future expansion. Do not start without fresh, explicit owner approval and roadmap reactivation.

Dependencies: `WP-D4`; approved navigation and biography facts from `WP-O3`/`WP-O4`.

Implementation:

- Change the homepage navigation label from About to Home and add a dedicated About page.
- Strengthen the homepage's primary value proposition and use one stable, direct hero message.
- Build an expert biography using only verified facts; explain the virtual process, who E&N serves, and why clients can trust the firm.
- Add breadcrumbs and update navigation, sitemap, metadata, and schema.

Acceptance: navigation is consistent; About content is factual and useful; no private details or unsupported credential claims appear.

Commit: `Improve site architecture and company story`

Next prompt:

> Read `production-roadmap.md` and `AGENTS.md`, run the Session Protocol preflight, and if it passes, do WP-D6 in Plan mode. Show me the plan and wait for approval before implementing. Complete only WP-D6, verify its acceptance criteria, commit, push, and end with the exact WP-D7 prompt from the roadmap.

### [ ] WP-D6 — Individual Service Pages

Status: unlikely future expansion. Do not start without fresh, explicit owner approval and roadmap reactivation.

Dependencies: `WP-D5`; service facts and priorities from `WP-O3`/`WP-O4`.

Implementation:

- Retain a Services hub and add substantive pages for Individual Tax Preparation, Business Tax Preparation, Bookkeeping, Quarterly Estimated Taxes, and Tax Consulting.
- Give each page a distinct audience, inclusions, process, FAQs, internal links, source references where needed, and consultation CTA.
- Avoid thin location variants, keyword stuffing, promises of tax outcomes, and unsupported “nationwide” claims.
- Update sitemap, breadcrumbs, navigation pathways, schema, and tests.

Acceptance: five useful, non-duplicative service pages are crawlable and internally linked; all claims are owner-approved.

Commit: `Add detailed tax and accounting service pages`

Next prompt:

> Read `production-roadmap.md` and `AGENTS.md`, run the Session Protocol preflight, and if it passes, do WP-D7 in Plan mode. Show me the plan and wait for approval before implementing. Complete only WP-D7, verify its acceptance criteria, commit, push, and end with the exact WP-D8 prompt from the roadmap.

### [ ] WP-D7 — Resource Center and Expert Content

Status: unlikely future expansion. Do not start without fresh, explicit owner approval and roadmap reactivation.

Dependencies: `WP-D6`; owner-reviewed subject matter.

Implementation:

- Turn Resources into a hub for E&N-authored guidance plus curated IRS links.
- Add an article template with author, reviewed date, primary sources, disclaimer, related services, and update workflow.
- Publish the first two or three owner-reviewed resources, prioritizing document checklists, estimated-tax fundamentals, and bookkeeping readiness.
- Use descriptive headings and direct answers for humans and answer engines without manufacturing keyword variants.

Acceptance: resources provide original value beyond link aggregation; tax statements cite primary sources and have owner review dates.

Commit: `Build expert tax resource center`

Next prompt:

> Read `production-roadmap.md` and `AGENTS.md`, run the Session Protocol preflight, and if it passes, do WP-D8 in Plan mode. Show me the plan and wait for approval before implementing. Complete only WP-D8, verify its acceptance criteria, commit, push, and end with the exact WP-D9 prompt from the roadmap.

### [ ] WP-D8 — Conversion, Trust, and Legal Pages

Status: unlikely future expansion. Do not start without fresh, explicit owner approval and roadmap reactivation.

Dependencies: `WP-D7`; decisions and approved drafts from `WP-O5`.

Implementation:

- Align all CTA wording with the actual consultation workflow.
- Reduce contact-form friction while clearly warning users not to submit sensitive tax identifiers or documents.
- Add approved Privacy, Terms, tax-information disclaimer, and Accessibility pages.
- Implement scheduler or secure-portal links only if approved and configured.
- Add privacy-conscious analytics events for consultation CTA clicks, successful form submissions, and key service navigation.

Acceptance: CTA promises match behavior; legal/trust pages are linked globally; no sensitive form data enters analytics; conversion events test successfully.

Commit: `Improve consultation flow and trust content`

Next prompt:

> Read `production-roadmap.md` and `AGENTS.md`, run the Session Protocol preflight, and if it passes, do WP-D9 in Plan mode. Show me the plan and wait for approval before implementing. Complete only WP-D9, verify its acceptance criteria, commit, push, and end with the roadmap maintenance prompt.

### [x] WP-D9 — Production Validation and Indexing Handoff

Dependencies: `WP-D1` through `WP-D4`; any future expansion package explicitly reactivated by the owner; `WP-O2` account access/results.

Status: completed July 15, 2026. Production validation aligned the five canonical pages with Cloudflare Pages' extensionless routes, confirmed the permanent apex-to-`www` redirect, and resolved the in-scope SEO, responsive-image, CSP, form-feedback, and link-label defects found during the audit.

Implementation:

- Crawl the complete production site for status codes, redirects, canonicals, metadata, headings, broken links, sitemap coverage, robots rules, and structured-data validity.
- Run desktop/mobile performance and accessibility checks on representative templates.
- Verify forms, analytics events, CSP, security headers, and error/404 behavior.
- Produce a concise baseline report and exact Search Console/Bing resubmission checklist.
- Resolve in-scope defects found by validation before completing the package.

Acceptance: no critical crawl, schema, accessibility, performance, form, or security regression remains; owner receives indexing instructions and a measurement baseline.

Commit: `Complete production SEO validation`

Maintenance prompt:

> Read `production-roadmap.md` and `AGENTS.md`, run the Session Protocol preflight, and review production search health in Plan mode. Show me the plan before implementing. Use Search Console/Bing findings and current site data to propose one bounded maintenance package; complete, verify, commit, and push only after I approve it.

## Maintenance Track

### [x] MP-1 — Sitemap Freshness Signals

Dependencies: completed `WP-O2` dashboard verification and indexed canonical pages.

Status: completed July 15, 2026. The sitemap now reports accurate significant-update dates for the five canonical pages and omits crawler hints that Google ignores. The artifact check enforces valid, non-future modification dates and rejects obsolete frequency and priority fields.

Implementation:

- Record the owner-confirmed Google Search Console and Bing Webmaster Tools status without credentials or private account data.
- Add accurate `lastmod` values for all five canonical sitemap URLs.
- Remove ignored `changefreq` and `priority` sitemap values.
- Extend the public-artifact check to reject missing, duplicate, invalid, or future `lastmod` dates and obsolete sitemap signals.

Acceptance: both search-engine dashboards report the five extensionless canonical pages indexed without crawl or canonical errors; the sitemap contains each canonical page exactly once with a valid modification date; clean builds and deliberate invalid-sitemap tests pass.

Commit: `Improve sitemap freshness signals`

Next prompt:

> Read `production-roadmap.md` and `AGENTS.md`, run the Session Protocol preflight, and review production search health in Plan mode. Show me the plan before implementing. Use Search Console/Bing findings and current site data to propose one bounded maintenance package; complete, verify, commit, and push only after I approve it.

## Recommended Parallel Sequence

| Development session | Owner work that can happen simultaneously |
|---|---|
| `WP-D1` | `WP-O1`, start `WP-O2` |
| `WP-D1A` | Confirm the Cloudflare Pages build command and output directory; continue `WP-O2` |
| `WP-D2` | Finish `WP-O3` and provide verified profiles |
| `WP-D3` | Complete `WP-O4`; draft service FAQs |
| `WP-D4` | Keep the current five-page architecture unless the owner later reactivates expansion |
| `WP-D5`–`WP-D7` | Unlikely future expansion; no work without fresh owner approval |
| `WP-D8` | Unlikely future expansion; `WP-O6` listing cleanup may continue independently |
| `WP-D9` | Finish `WP-O2`; capture measurement baseline |

## Success Measures

- One canonical HTTPS hostname and clean crawler directives.
- Only approved public pages/assets are deployed; repository-only files and dead/commented-out features are not production-accessible.
- All intended URLs indexed without duplicate-host or canonical conflicts.
- Good Core Web Vitals or a documented path to field-data improvement.
- Accurate entity data across the site and major business profiles.
- Search impressions for service-intent and branded queries trend upward.
- ChatGPT/Claude search crawlers remain allowed while training policy follows the owner's choice.
- Consultation submissions and qualified conversion rate are measurable.
- Current pages remain consistent through shared-layout validation; any future page expansion requires a new architecture decision.
