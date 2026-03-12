# E&N Tax & Accounting — Project TODO

Status key: ✅ Done · 🔄 In Progress / Blocked · ⬜ To Do · 💬 Needs Decision

---

## 🚀 Launch Blockers (must finish before going live)

- ✅ **Domain** — `entaxaccounting.com` is registered through Google Workspace (Domains tab in Google Admin). No action needed.
- ⬜ **Cancel Wix** — redundant, not needed
- ⬜ **Sign up for Netlify** — netlify.com, use Google login
- ⬜ **Deploy site to Netlify** — drag project folder (after deleting `deprecated/`) into Netlify deploy area
- ⬜ **Connect domain to Netlify** — add DNS records Netlify provides into wherever domain is registered
- ⬜ **Fix contact form** — currently shows a fake success alert and sends nothing
  - Sign up at formspree.io (free, 50 submissions/month)
  - Create a form, get the endpoint ID (looks like `abcdefgh`)
  - Share the ID here and Claude will update Contact.html

---

## 📋 Pre-Deploy Cleanup

- ⬜ **Back up `deprecated/` folder** — copy to Google Drive or local backup, then delete from project
  - Contains: Blog.html, blog-posts.json, Shop.html, blog-manager, Python scripts, guides, broken tool
- ⬜ **Commit all pending git changes** — large batch of uncommitted work sitting in working tree
  - New files to `git add`: CLAUDE.md, Resources.html, _headers, TODO.md, SITE_NOTES.md
  - Everything else is already staged or modified

---

## 🏗️ Content / Page Updates

- ⬜ **Remove "Tax Planning Strategies" from Contact.html dropdown** — line 966, service interest select menu. User handling this manually.
- ⬜ **Google Business Profile** — set up at business.google.com (free)
  - Required before Reviews page is useful
  - Once set up: replace placeholder link in Reviews.html (search for `REPLACE-WITH-GOOGLE-PROFILE-LINK`)
- ⬜ **Reviews page — add first real reviews** — when clients start leaving reviews, add them using the commented-out template in Reviews.html. Instructions are embedded in the HTML comment.
- 💬 **Reviews hero background** — currently using `lighthouse.png`. Swap for a different image from `images/backgrounds/` if preferred.
- 💬 **Portrait sizing** — `portrait.png` is set to max-width 400px on the About page. Adjust in Index.html (`.family-photo` CSS) if it needs to be larger or smaller.

---

## 🛒 Shop (on hold)

- ⬜ **Finalize products** — work in progress; files are in `pro_tools/`
- ⬜ **Restore Shop to nav** — when ready, search `<!-- <li><a href="shop.html">Shop</a></li> -->` across all pages and uncomment
- ⬜ **Restore Shop.html** — it's in `deprecated/Shop.html`, move back to root when ready

---

## 🔒 Security (post-launch)

- ✅ **Security headers file** — `_headers` created for Netlify (X-Frame-Options, nosniff, Referrer-Policy)
- ⬜ **Verify HTTPS** — Netlify provisions this automatically once domain is connected; confirm padlock shows
- ⬜ **Formspree spam protection** — Formspree free tier includes basic spam filtering; no extra action needed

---

## ✅ Completed

- ✅ Added **Tax Consulting** service card to Services page
- ✅ Removed **Blog** from all page navs, footers, and homepage section
- ✅ Moved Blog files to `deprecated/` (Blog.html, blog-posts.json, blog-manager, Python scripts, guides)
- ✅ Removed **Shop** from all page navs and footers (commented out for easy restore)
- ✅ Moved Shop.html to `deprecated/`
- ✅ Replaced **FamilyPhotoshootPhoto.JPG** with **portrait.png** on About page
- ✅ Added caption "Marija Sparano, Founder & CEO" under portrait
- ✅ Created new **Reviews.html** — on-brand, coming soon state, with review card template embedded
- ✅ Added **Reviews** link to nav and footer on all live pages
- ✅ Created **Netlify `_headers`** security file
- ✅ Cleaned up `.gitignore` (added Python cache, generated files)
- ✅ Rewrote **CLAUDE.md** with accurate project documentation
- ✅ Moved all deprecated/unused files to `deprecated/` folder using `git mv`
- ✅ Removed empty `guides/` directory

---

## 💡 Future Ideas (no timeline)

- Blog — wife may want to revisit once the firm is more established
- Shop — digital products / downloadable tools (files exist in `pro_tools/`)
- Google Reviews embed widget — once reviews accumulate, consider Elfsight (~$9/mo) to auto-display them
- Testimonials section on homepage — pull 1–2 strong reviews into the Index.html hero or about section
