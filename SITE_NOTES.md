# E&N Tax & Accounting — Site Notes

Reference doc for content decisions, brand guidelines, and how things are wired together.
Bring this file (along with TODO.md and CLAUDE.md) into any new chat session for context.

---

## Brand

**Colors**
- Navy: `#003366` — primary, headers, buttons
- Gold: `#f2b90c` — accents, hover states, CTA buttons
- Slate: `#1c3a53` — secondary backgrounds
- Off-white: `#f8f9fa` — page background, card backgrounds
- Dark text: `#2C3E50`

**Voice & Tone**
- Warm and personal, not corporate
- Family-centered ("clients become part of an extended family")
- Professional but approachable
- Named after twin daughters Emma and Nina
- Founder: Marija Sparano

**Avoid in copy**
- "Strategy" / "strategies"
- "Planning" (in a tax context)

---

## Pages

| Page | File | Status | Notes |
|---|---|---|---|
| About / Home | Index.html | Live | Hero carousel (5 slides), Who We Are section with portrait, client type cards |
| Services | Services.html | Live | 4 active cards: Individual Tax, Business Tax, Bookkeeping, Quarterly Estimates, Tax Consulting |
| Resources | Resources.html | Live | Links to tools in `tools/` directory |
| Reviews | Reviews.html | Live (coming soon) | No reviews yet; template embedded in HTML comment for when they arrive |
| Contact | Contact.html | Live | Form is NOT wired up yet — needs Formspree (see TODO) |
| Shop | deprecated/Shop.html | Hidden | Commented out of nav; restore when products are ready |
| Blog | deprecated/Blog.html | Removed | Wife decided not to maintain; all references removed |

---

## Services Offered

1. **Individual Tax Prep** — individuals & families
2. **Business Tax Prep** — small businesses under $1M revenue
3. **Bookkeeping Services** — monthly statements, reconciliation, ledger
4. **Tax Consulting** — entity selection, new business setup, one-time or ongoing advisory
5. **Quarterly Tax Estimates** — projections, safe harbor, payment vouchers

*Commented out (was never launched): Tax Planning Strategies card*

---

## Tech Stack

- Pure static HTML/CSS/JS — no frameworks, no build tools
- Every page is self-contained with its own `<style>` and `<script>`
- No shared components — nav/footer/CSS are copy-pasted across pages
- Hosted on **Netlify** (free tier) — pending domain setup
- Domain: **entaxaccounting.com** — pending recovery/registration
- Email: **info@entaxaccounting.com** via Google Workspace ($7/mo)

**Updating any shared element (nav, footer, color palette) requires editing every HTML file individually.**

---

## Tools Directory (`tools/`)

Standalone interactive calculators — no nav/footer, self-contained:
- `quarterly-tax-calculator.html`
- `tax-withholding-estimator.html`
- `rental-property-calculator.html`
- `tax-calendar-2025.html`
- `depreciation-schedule-tool.html`
- `1099-contractor-checklist.html`

---

## Images

| Location | Contents |
|---|---|
| `images/` | Logo (`E_N_LOGO.png`), portrait (`portrait.png`), client type illustrations |
| `images/backgrounds/` | Hero backgrounds: `services.jpeg`, `contact-us.png`, `tools.jpeg`, `lighthouse.png`, `city.png`, `waterfall.png`, others |
| `images/featured/` | Blog category images — no longer in use (blog removed) |

---

## Contact Form

The form in Contact.html is **not functional** — it currently shows a fake alert.
Fix: Sign up at formspree.io, get a form endpoint ID, share it in chat.
Claude will wire up the AJAX submission to Formspree.

---

## Reviews

- No reviews exist yet (firm established 2024)
- Reviews.html is live but in "coming soon" state
- When first reviews come in: open Reviews.html, find the HTML comment block labeled TEMPLATE, uncomment it, and fill in the details
- Google review link placeholder in Reviews.html: search `REPLACE-WITH-GOOGLE-PROFILE-LINK`
- Google Business Profile: set up at business.google.com

---

## Git / Deployment Notes

- Branch: `main`
- Large batch of uncommitted changes pending (see TODO → Pre-Deploy Cleanup)
- `deprecated/` folder: back up externally then delete — it will then be committed as a batch of deletions
- Deploy to Netlify: drag project folder into Netlify UI, or connect GitHub repo for auto-deploys
- Security headers: `_headers` file in project root — Netlify reads this automatically
