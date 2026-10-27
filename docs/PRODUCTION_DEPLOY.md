# SilaiSetu — production deploy (upload everything)

End-to-end runbook to put **database**, **backend API**, and **web frontend** live.

Stack: **GitHub → Neon (Postgres) → Render (Nest API) → Cloudflare Pages (Vite web)**.  
Android / Play Store upload is out of scope (Flutter app points at the live API with `API_BASE_URL`).

Passwords, JWT secrets, and DB URL live only in **[`CREDENTIALS.local.md`](CREDENTIALS.local.md)** (gitignored — never push).

---

## Live URLs

| Layer | URL |
| --- | --- |
| GitHub | https://github.com/flutterDeveloper2206/silaisetu |
| API | https://silaisetu.onrender.com/api/v1 |
| Swagger | https://silaisetu.onrender.com/docs |
| Health | https://silaisetu.onrender.com/api/v1/health |
| Web (shop + platform admin) | https://silaisetu.pages.dev |
| Platform admin login | https://silaisetu.pages.dev/platform-admin/login |
| Neon console | https://console.neon.tech/app/projects/raspy-cloud-55647884 |
| Render dashboard | https://dashboard.render.com |
| Cloudflare Pages | https://dash.cloudflare.com |

---

## Architecture (what uploads where)

```text
Your laptop
   │  git push
   ▼
GitHub (source of truth)
   ├── Render builds root Dockerfile → Nest API + prisma migrate deploy
   └── Cloudflare Pages builds frontend/ → static Vite site

Neon Postgres  ←── DATABASE_URL (Render env + local migrate/seed)
```

| Piece | Hosted on | How it updates |
| --- | --- | --- |
| **DB schema + data** | Neon | `prisma migrate deploy` (Render on boot + optional laptop) / `prisma db seed` (laptop once) |
| **Backend API** | Render Docker | Push `main` → auto rebuild, or Manual Deploy |
| **Frontend web** | Cloudflare Pages | Push `main` → auto build, or Retry deployment |
| **Flutter app** | Device / APK | `flutter run` / build with live `API_BASE_URL` (not store) |

---

## Free-tier limits

- **Render** free Web Service sleeps after idle → cold start 30–60s; hit `/api/v1/health` before demos.
- **Neon** free projects can suspend when inactive.
- Fine for a public demo, not a hard SLA.
- Uploaded subscription QR / payment screenshots on Render free disk are **ephemeral** (lost on redeploy). Re-upload QR after rebuild if needed, or move uploads to object storage later.

---

# A. First-time production setup

Do these once in order.

## A1. Upload code → GitHub

From the monorepo root (`tailor /`):

```bash
git status
git add -A
git commit -m "Describe your change"
git push origin main
```

Repo: `https://github.com/flutterDeveloper2206/silaisetu.git`

If push asks for login: Chrome → GitHub authorize → retry.

**Never commit:** `.env`, `CREDENTIALS.local.md`, `backend/uploads/`, secrets.

---

## A2. Database → Neon

### Create / open project

1. Chrome → https://console.neon.tech → project **silaisetu** (`raspy-cloud-55647884`).
2. Copy connection string with `sslmode=require` (pooler URL is fine for the API).
3. Store as Render env `DATABASE_URL` and in `CREDENTIALS.local.md` only.

### Apply migrations + seed (from your laptop)

Always run against **Neon**, not local Postgres, when preparing production:

```bash
cd backend
export DATABASE_URL='postgresql://…neon…?sslmode=require'

# Create/update tables from prisma/migrations/*
npx prisma migrate deploy

# Demo shops, platform admin, subscription settings (idempotent)
export PLATFORM_ADMIN_EMAIL='admin@silaisetu.com'
export PLATFORM_ADMIN_PASSWORD='SilaiSetu_Admin_2026!'
export DEMO_OWNER_PASSWORD='SilaiSetu_Owner_2026!'
npx prisma db seed
```

What seed sets:

- Platform admin + demo owners (see `CREDENTIALS.local.md`)
- Demo shops marked **lifetime free** (no paywall)
- Subscription settings with **`subscription.enabled = false`** until you turn it on in admin

### After every Prisma schema change

```bash
cd backend
# Locally create a migration while developing:
# npx prisma migrate dev --name short_description

git add prisma/migrations prisma/schema.prisma
git commit -m "Add DB migration …"
git push origin main
```

Render’s Docker start command runs `npx prisma migrate deploy` on each deploy, so Neon schema updates when the API redeploys.

---

## A3. Backend → Render (Nest API)

### Create service (first time only)

1. Chrome → https://dashboard.render.com → sign in → connect GitHub.
2. **New → Web Service** → select `flutterDeveloper2206/silaisetu`.
3. Settings:
   - **Root Directory:** leave **empty** (repo-root [`Dockerfile`](../Dockerfile) builds `backend/`)
   - **Dockerfile Path:** `./Dockerfile`
   - **Runtime:** Docker
4. Environment variables (full list also in [`CREDENTIALS.local.md`](CREDENTIALS.local.md) / [`backend/.env.production.example`](../backend/.env.production.example)):

| Key | Value |
| --- | --- |
| `DATABASE_URL` | Neon URL with `sslmode=require` |
| `JWT_ACCESS_SECRET` | long random (≥32 chars) |
| `JWT_REFRESH_SECRET` | long random (≥32 chars) |
| `JWT_ACCESS_EXPIRES` | `30d` |
| `JWT_REFRESH_EXPIRES` | `30d` |
| `NODE_ENV` | `production` |
| `COOKIE_SECURE` | `true` |
| `AUTH_DEV_EXPOSE_CODES` | `false` |
| `AUTH_REQUIRE_VERIFICATION` | `false` |
| `API_PREFIX` | `api/v1` |
| `THROTTLE_TTL_MS` | `60000` |
| `THROTTLE_LIMIT` | `100` |
| `APP_VERSION` | `0.1.0` |
| `SUPPORT_EMAIL` | `support@silaisetu.com` |
| `PLATFORM_ADMIN_EMAIL` | (optional; used when seeding) |
| `PLATFORM_ADMIN_PASSWORD` | (optional; used when seeding) |
| `PORT` | Render sets this; Dockerfile respects `PORT` |

5. **Create Web Service** → wait for build + deploy.

### Confirm API is live

```bash
curl -sS https://silaisetu.onrender.com/api/v1/health
# expect: "status":"ok","database":"ok"
```

- Swagger: https://silaisetu.onrender.com/docs  
- If first request times out: wait 30–60s (cold start) and retry.

### Redeploy backend (after code push)

1. `git push origin main`, **or**
2. Render → service **silaisetu** → **Manual Deploy → Deploy latest commit**

Boot always runs: `prisma migrate deploy && node dist/main`.

---

## A4. Frontend → Cloudflare Pages (Vite web)

### Create project (first time only)

1. Chrome → https://dash.cloudflare.com → **Workers & Pages** → Create → Pages → Connect to Git.
2. Select `flutterDeveloper2206/silaisetu`.
3. Build settings:

| Setting | Value |
| --- | --- |
| **Root directory** | *(leave blank)* |
| **Build command** | `cd frontend && npm install && npm run build` |
| **Build output directory** | `frontend/dist` |
| **Production env** | `VITE_API_URL` = `https://silaisetu.onrender.com/api/v1` |

4. Save and deploy. Site: https://silaisetu.pages.dev

See [`frontend/.env.production.example`](../frontend/.env.production.example).

### Redeploy frontend (after UI changes)

1. Push `main`, **or**
2. Cloudflare Pages → project **silaisetu** → **Deployments → Retry deployment**

If the API URL changes, update `VITE_API_URL` and redeploy (Vite bakes it in at build time).

### Smoke-test web

- Shop app: https://silaisetu.pages.dev → sign in as owner  
- Platform admin: https://silaisetu.pages.dev/platform-admin/login → admin credentials from `CREDENTIALS.local.md`

---

## A5. Flutter app → live API

Default in code is production:

`https://silaisetu.onrender.com/api/v1`

([`app/lib/core/config/api_config.dart`](../app/lib/core/config/api_config.dart))

```bash
cd app
flutter pub get
flutter run -d <device_id>
# Optional explicit override:
# flutter run -d <device_id> --dart-define=API_BASE_URL=https://silaisetu.onrender.com/api/v1

# Local Nest instead:
# flutter run -d <device_id> --dart-define=API_HOST=192.168.1.39
```

No Play Store upload in this runbook.

---

## A6. Subscription (QR paywall) — production config

Feature ships **off** until you enable it.

1. Open platform admin → **Settings**.
2. Set **amount (INR)**, **trial days** (default 30), **paid days** (default 365).
3. Set **UPI ID** and short **instructions**.
4. **Upload QR image**.
5. Toggle **Enforce subscription** only after QR/UPI look correct.
6. **Shops** → open a shop → mark **Lifetime free** for partners who should never see the paywall (demo shops are already lifetime free via seed).
7. **Subscription proofs** → Approve / Reject owner submissions (approve grants `paidDays` from now or from current expiry).

API used by the app:

- `GET /api/v1/billing/subscription`
- `POST /api/v1/billing/subscription/proof` (screenshot + transaction ID)

---

# B. Everyday update checklist (all layers)

When you change code and want production updated:

### 1. Database (only if Prisma schema changed)

```bash
cd backend
export DATABASE_URL='…neon…'
npx prisma migrate deploy   # or rely on Render boot after push
# n px prisma db seed       # only if you need demo/settings re-applied
```

### 2. Upload code

```bash
git add -A
git commit -m "Your message"
git push origin main
```

### 3. Backend

- Wait for Render auto-deploy, or **Manual Deploy**.
- Check https://silaisetu.onrender.com/api/v1/health

### 4. Frontend

- Wait for Cloudflare Pages build, or **Retry deployment**.
- Hard-refresh https://silaisetu.pages.dev

### 5. Flutter

- Rebuild/reinstall on device if Dart code changed.
- Confirm logs hit `https://silaisetu.onrender.com/api/v1/...` (not `192.168.x.x`).

---

# C. Smoke checklist

- [ ] `GET /api/v1/health` → `ok` / database `ok`
- [ ] Swagger loads: `/docs`
- [ ] Web HTTPS loads: https://silaisetu.pages.dev
- [ ] Platform admin login works
- [ ] Shop owner login works; create customer + order
- [ ] Flutter on device uses live API
- [ ] (Optional) Subscription: QR uploaded, enforcement on, proof approve unlocks access
- [ ] Live URLs table at top of this file still correct

---

# D. Ops tips

| Issue | Fix |
| --- | --- |
| API timeout / empty response | Free Render asleep → hit health, wait 30–60s |
| Login 500 after schema change | Run `prisma migrate deploy` against Neon; check Render logs |
| Web talks to wrong API | Rebuild Pages with correct `VITE_API_URL` |
| Flutter still hits LAN IP | Rebuild without `API_HOST`; use live default or `API_BASE_URL` |
| QR missing after Render redeploy | Free disk wiped → re-upload QR in platform Settings |
| Rotate secrets | Change JWT_* in Render → Manual Deploy; users must sign in again |

---

# E. Rollback (high level)

1. **Code:** Render / Cloudflare → redeploy a previous successful commit.
2. **DB:** Prefer forward-fix migrations. Do not `migrate reset` on production Neon.
3. **Feature flags:** Turn **Enforce subscription** off in platform Settings to restore access immediately without a redeploy.
