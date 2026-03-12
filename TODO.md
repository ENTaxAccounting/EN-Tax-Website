# E&N Tax & Accounting — Project TODO

Status key: ✅ Done · 🔄 In Progress / Blocked · ⬜ To Do · 💬 Needs Decision

---

## 🚀 Launch Blockers

- ✅ **Domain** — `entaxaccounting.com` registered at Squarespace (migrated from Google Domains 2023)
- ✅ **Sign up for Netlify** — done
- ✅ **Deploy site to Netlify** — live at entaxaccounting.com
- ✅ **Connect domain to Netlify** — DNS records added in Squarespace
- ✅ **Verify HTTPS** — SSL provisioned by Netlify, padlock confirmed
- ✅ **Fix contact form** — Formspree wired up (endpoint: xeergwwe); honeypot spam protection added
- ⬜ **Cancel Wix** — redundant, still active

---

## 📋 Post-Launch Cleanup

- ⬜ **Formspree domain restriction** — add `entaxaccounting.com` to allowed domains in Formspree dashboard (formspree.io → your form → Settings → Allowed Domains)
- ⬜ **Test contact form on live domain** — submit a real test from entaxaccounting.com to confirm end-to-end

---

## 🏗️ Content / Page Updates

- ✅ **Remove "Tax Planning Strategies" from Contact.html dropdown** — replaced with "Tax Consulting"
- ✅ **Google Business Profile** — set up; review link updated in Reviews.html (https://g.page/r/CQg5gRyJ4mdoEAE/review)
- ⬜ **Reviews page — add first real reviews** — when clients start leaving reviews, add them using the commented-out template in Reviews.html. Instructions are embedded in the HTML comment.
- 💬 **Reviews hero background** — currently using `lighthouse.png`. Swap for a different image from `images/backgrounds/` if preferred.
- 💬 **Portrait sizing** — `portrait.png` is set to max-width 400px on the About page. Adjust in Index.html (`.family-photo` CSS) if it needs to be larger or smaller.

---

## 🛒 Shop (on hold)

- ⬜ **Restore Shop** — when ready, recover files from external backup, add Shop.html to root, uncomment nav links across all pages

---

## 🔒 Security

- ✅ **Security headers file** — `_headers` created for Netlify (X-Frame-Options, nosniff, Referrer-Policy)
- ✅ **HTTPS** — confirmed live
- ✅ **Formspree honeypot** — in place

---

## ✅ Completed

- ✅ Site live at entaxaccounting.com via Netlify
- ✅ GitHub org created: ENTaxAccounting; repo transferred and public
- ✅ Auto-deploy configured: push to main → Netlify deploys in ~30s
- ✅ DNS configured at Squarespace (A record + CNAME → Netlify)
- ✅ info@ email set up as Google Group alias forwarding to marija@
- ✅ Contact form wired to Formspree (xeergwwe)
- ✅ Google Business Profile live; review link in Reviews.html
- ✅ Added Tax Consulting service card
- ✅ Removed Blog and Shop from nav (commented out for restore)
- ✅ Created Resources.html, Reviews.html, CLAUDE.md, TODO.md, SITE_NOTES.md, _headers
- ✅ Deleted deprecated/ and pro_tools/ and images/featured/
- ✅ Portrait (portrait.png) on About page with Marija's caption

---

## 💡 Future Ideas (no timeline)

- Blog — Marija may want to revisit once the firm is more established
- Shop — digital products / downloadable tools
- Google Reviews embed widget — once reviews accumulate, consider Elfsight (~$9/mo) to auto-display them
- Testimonials section on homepage — pull 1–2 strong reviews into Index.html
