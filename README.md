# ASAP Credit Repair — Consultation Notes Producer

Multi-user web app for generating structured credit consultation notes from uploaded PDF reports. Built on Netlify + Supabase.

---

## Architecture

| Layer | What it does |
|---|---|
| **GitHub** | Version control. Push changes → Netlify auto-deploys |
| **Netlify** | Hosts the HTML files + runs the serverless `analyze` function |
| **Netlify Function** | Calls the Anthropic API — API key never touches the browser |
| **Supabase** | User login (each consultant has an account) + stores consultation history |

---

## One-Time Setup (30–45 minutes)

### Step 1 — GitHub

1. Go to [github.com](https://github.com) → **New repository**
2. Name it `asap-consultation-notes` (or whatever you like)
3. Set to **Private**, click **Create repository**
4. Upload all files from this folder into the repo (drag & drop in GitHub UI, or use Git)

---

### Step 2 — Supabase

1. Go to [supabase.com](https://supabase.com) → your existing project (or create new)
2. In the left menu → **SQL Editor** → paste the entire contents of `supabase-setup.sql` → click **Run**
3. Go to **Settings → API** and copy two values:
   - **Project URL** (looks like `https://xxxx.supabase.co`)
   - **anon public** key (long string starting with `eyJ...`)

4. Open `login.html` and `app.html` in a text editor and replace:
   ```
   const SUPABASE_URL  = 'YOUR_SUPABASE_URL';
   const SUPABASE_ANON = 'YOUR_SUPABASE_ANON_KEY';
   ```
   with your actual values. Save both files and push/re-upload to GitHub.

---

### Step 3 — Anthropic API Key

1. Go to [console.anthropic.com](https://console.anthropic.com) → **API Keys** → create a new key
2. Copy it (starts with `sk-ant-`)
3. Keep it handy for Step 4

---

### Step 4 — Netlify

1. Go to [netlify.com](https://netlify.com) → **Add new site → Import an existing project**
2. Connect to GitHub → select your `asap-consultation-notes` repo
3. Build settings (leave as defaults — no build command needed)
4. Click **Deploy site**

**Add environment variables** (this is where secrets live):
1. In Netlify dashboard → **Site configuration → Environment variables → Add variable**
2. Add these three:

| Key | Value |
|---|---|
| `ANTHROPIC_API_KEY` | Your Anthropic key (`sk-ant-...`) |
| `SUPABASE_URL` | Your Supabase project URL |
| `SUPABASE_ANON_KEY` | Your Supabase anon key |

3. Go to **Deploys** → **Trigger deploy** to pick up the new env vars

---

### Step 5 — Create user accounts

Each consultant needs an account. Two options:

**Option A — Self-signup (anyone with the link can sign up):**
- Just share the site URL. Consultants click "Create Account" on the login page.

**Option B — Admin-only signup (you invite people):**
1. In Supabase dashboard → **Authentication → Settings**
2. Turn off **Enable email signup** under "Email Auth"
3. To add users: go to **Authentication → Users → Add user**

---

## Making Changes

### Update the AI prompt (fix how it reads reports)

1. Open `netlify/functions/analyze.js` in GitHub
2. Edit the `SYSTEM_PROMPT` variable (the big text block at the top)
3. Commit → Netlify auto-redeploys in ~1 minute

### Change the app design or behavior

- `app.html` — main app UI and logic
- `login.html` — login/signup page
- `netlify/functions/analyze.js` — the AI prompt and API call

All changes: edit in GitHub → commit → auto-deploys.

---

## Troubleshooting

**"Unauthorized" error in the app**
→ Sign out and sign back in. Sessions expire after 1 hour by default.
→ In Supabase → Authentication → Settings, increase JWT expiry if needed.

**"Timeout" error on large reports**
→ The Netlify free tier has a 26-second function timeout.
→ Upgrade to Netlify Pro ($19/mo) to increase timeout to 30s.
→ Or try uploading one bureau at a time instead of all three.

**Report has wrong account count**
→ The AI prompt in `analyze.js` controls how reports are read.
→ Edit `SYSTEM_PROMPT` to add/fix specific rules for that report format.
→ See the comment at the top of `analyze.js` for guidance.

**User can't log in**
→ Check Supabase → Authentication → Users to confirm account exists.
→ User may need to confirm their email (check Supabase → Authentication → Settings → Email confirmation).
→ To disable email confirmation: Authentication → Settings → uncheck "Enable email confirmations".

**Notes not saving to history**
→ Check Supabase → Table Editor → consultations to see if rows are being created.
→ If not, the RLS policies may need to be re-run. Re-run `supabase-setup.sql`.

---

## File Structure

```
asap-notes-app/
├── login.html                    ← Login / signup page
├── app.html                      ← Main consultation notes app
├── netlify/
│   └── functions/
│       └── analyze.js            ← AI prompt + Anthropic API call (EDIT THIS TO FIX AI BEHAVIOR)
├── netlify.toml                  ← Netlify config (function timeout, redirects)
├── package.json                  ← Supabase SDK dependency
├── supabase-setup.sql            ← Run once in Supabase SQL Editor
└── README.md                     ← This file
```
