# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Static HTML website for E&N Tax & Accounting, a virtual tax and accounting firm founded by **Marija Sparano** in 2024. Named after her twin daughters Emma and Nina. No build tools, package managers, or compilation — all development is done directly on HTML/CSS/JS files.

## Brand

**Voice:** Warm and personal, family-centered, professional but approachable. Clients are treated like family.
**Avoid in copy:** the words "strategy", "strategies", or "planning" in a tax context — owner's preference.
**Founder:** Marija Sparano, Founder & CEO

**Color palette** (defined in `:root` in every page's `<style>` block):
```css
--primary-color: #003366;   /* Navy */
--secondary-color: #f2b90c; /* Gold */
--accent-color: #1c3a53;    /* Slate */
--text-light: #f8f9fa;
--text-dark: #2C3E50;
```

## Live Pages & Current State

| Page | File | Notes |
|---|---|---|
| About / Home | `Index.html` | Hero carousel, "Who We Are" with Marija's portrait, client type cards |
| Services | `Services.html` | 4 active service cards (see Services section below) |
| Resources | `Resources.html` | Links to tools in `tools/` |
| Reviews | `Reviews.html` | Coming soon — no reviews yet; template embedded in HTML comment |
| Contact | `Contact.html` | Formspree wired up (endpoint: xeergwwe), honeypot spam protection included |

**Removed/hidden pages:** Blog and Shop are commented out of all navs. Do not re-add without being asked.

## Services Offered

1. **Individual Tax Prep** — individuals & families
2. **Business Tax Prep** — small businesses under $1M revenue
3. **Bookkeeping Services** — monthly statements, reconciliation, ledger
4. **Tax Consulting** — entity selection, new business setup, one-time or ongoing advisory
5. **Quarterly Tax Estimates** — projections, safe harbor, payment vouchers

## Navigation (current — all live pages must match this)

About · Services · Resources · Reviews · Contact + "Book Consultation" CTA button

Each page has a sticky white header with `.nav-links` (ul > li > a) and a `.nav-cta` button. Mobile hamburger menu toggled via inline JS. **When adding/removing a nav item, update every HTML file individually** — there is no shared template.

## Key Architectural Patterns

**Shared code is copy-pasted, not shared.** Every page duplicates the same nav, footer, CSS variables, and base styles. Nav, footer, and palette changes require editing every file.

**Hero backgrounds** live in `images/backgrounds/`. Available: `services.jpeg`, `contact-us.png`, `tools.jpeg`, `lighthouse.png`, `city.png`, `waterfall.png`, `flowers.png`, `waterfall.png`, `blog.jpeg`, `shop.jpeg`.

**Tools** (`tools/` directory) are standalone calculators with no nav/footer:
`quarterly-tax-calculator.html`, `tax-withholding-estimator.html`, `rental-property-calculator.html`, `tax-calendar-2025.html`, `depreciation-schedule-tool.html`, `1099-contractor-checklist.html`

## Tech Stack & Hosting

- **Hosting:** Netlify (free tier) — auto-deploys on every push to `main`
- **Repo:** `github.com/ENTaxAccounting/EN-Tax-Website` (public, GitHub org)
- **Domain:** `entaxaccounting.com` — registered at Squarespace (migrated from Google Domains in 2023); DNS managed there. A record → `75.2.60.5`, www CNAME → Netlify subdomain.
- **Email:** Google Workspace — `marija@entaxaccounting.com`, `info@entaxaccounting.com` (info@ is a free Google Group alias forwarding to marija@)
- **Contact form:** Formspree endpoint `xeergwwe` — restrict allowed domain to `entaxaccounting.com` in Formspree dashboard
- **Google Business Profile:** live — review link `https://g.page/r/CQg5gRyJ4mdoEAE/review`

## Deploy Workflow

Edit files → `git add` → `git commit` → `git push` → Netlify auto-deploys in ~30 seconds.

## Pending Items (important for new sessions)

- **Formspree domain restriction** — add `entaxaccounting.com` to allowed domains in Formspree dashboard (not yet done)
- **Cancel Wix** — still active, redundant subscription
- **Reviews** — no reviews yet; template embedded in HTML comment in Reviews.html. When first reviews arrive, uncomment and fill in.

## File Organization

```
/
├── *.html              # Live public pages
├── _headers            # Netlify security headers (do not delete)
├── TODO.md             # Task tracker — check this at the start of each session
├── SITE_NOTES.md       # Detailed brand/content reference
├── images/
│   └── backgrounds/    # Hero background images
└── tools/              # Interactive tax calculators
```
