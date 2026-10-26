# SilaiSetu — free production deploy

Single runbook: **GitHub → Neon (DB) → Render (API) → Cloudflare Pages (Vite web)**.  
No Android / Play Store upload.

## Live URLs (fill after deploy)

| Layer | URL |
| --- | --- |
| GitHub | https://github.com/flutterDeveloper2206/silaisetu |
| API | `https://YOUR_SERVICE.onrender.com/api/v1` |
| Swagger | `https://YOUR_SERVICE.onrender.com/docs` |
| Health | `https://YOUR_SERVICE.onrender.com/api/v1/health` |
| Web | `https://YOUR_PAGES.pages.dev` |
| Database | Neon project `raspy-cloud-55647884` |

## Secrets (local only)

Passwords, JWT secrets, and `DATABASE_URL` are stored in **[`PRODUCTION_SECRETS.local.md`](PRODUCTION_SECRETS.local.md)** on your machine.  
That file is **gitignored** — never push it to GitHub. Use it when filling Render / Cloudflare env vars.

## Free-tier limits

- **Render** free Web Service sleeps after idle → cold starts; delivery-reminder cron may miss while asleep.
- **Neon** free projects can suspend when inactive.
- Fine for a public demo, not a hard SLA.

---

## 1. GitHub

Repo: `https://github.com/flutterDeveloper2206/silaisetu.git`

From the monorepo root:

```bash
echo "# silaisetu" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/flutterDeveloper2206/silaisetu.git
git push -u origin main
```

If push asks for login: open **Chrome** → GitHub sign-in / authorize, then retry.

Then add `.gitignore`, deploy files, and the full tree (`backend/`, `frontend/`, `app/`, `docs/`) and push:

```bash
git add -A
git commit -m "Add monorepo and production deploy scaffolding"
git push origin main
```

Never commit `.env` or real secrets.

---

## 2. Database — Neon

1. Open **Chrome** → https://console.neon.tech → sign in if needed.
2. Create project **silaisetu** (pick a region close to users).
3. Copy the connection string. Prefer one with `sslmode=require`.
4. Store it only as Render env `DATABASE_URL` (not in git).

---

## 3. Backend — Render

1. Open **Chrome** → https://dashboard.render.com → sign in; connect GitHub.
2. **New → Web Service** → select `flutterDeveloper2206/silaisetu`.
3. Settings:
   - **Root Directory:** `backend`
   - **Runtime:** Docker (uses [`backend/Dockerfile`](../backend/Dockerfile))
   - Or Native: Build `npm ci && npx prisma generate && npm run build`, Start `npx prisma migrate deploy && node dist/main`
4. Environment (from [`backend/.env.production.example`](../backend/.env.production.example)):

   | Key | Value |
   | --- | --- |
   | `DATABASE_URL` | Neon URL with `sslmode=require` |
   | `JWT_ACCESS_SECRET` | long random (≥32 chars) |
   | `JWT_REFRESH_SECRET` | long random (≥32 chars) |
   | `NODE_ENV` | `production` |
   | `COOKIE_SECURE` | `true` |
   | `AUTH_DEV_EXPOSE_CODES` | `false` |
   | `API_PREFIX` | `api/v1` |
   | `PORT` | `10000` (Render often sets this; Dockerfile listens via `PORT`) |

5. Deploy. Confirm:
   - `GET /api/v1/health` → `status: ok` / database ok
   - `/docs` Swagger loads
6. Optional one-time seed (Render shell): `npx prisma db seed` with `PLATFORM_ADMIN_*` set.

---

## 4. Frontend — Cloudflare Pages

1. Open **Chrome** → https://dash.cloudflare.com → **Workers & Pages** → Create → Pages → Connect to Git.
2. Select `flutterDeveloper2206/silaisetu`.
3. Build settings:
   - **Root directory:** `frontend`
   - **Build command:** `npm ci && npm run build`
   - **Build output directory:** `dist`
4. Environment variable:
   - `VITE_API_URL` = `https://YOUR_SERVICE.onrender.com/api/v1`
5. Deploy. Open the `*.pages.dev` URL and smoke-test register / sign-in.

See [`frontend/.env.production.example`](../frontend/.env.production.example).

---

## 5. Smoke checklist

- [ ] Web loads over HTTPS
- [ ] Register / sign-in against live API + Neon
- [ ] Create a customer and an order
- [ ] API health + Swagger reachable
- [ ] Update the **Live URLs** table at the top of this file

---

## Ops notes

- After Prisma schema changes: push to `main`, let Render rebuild (Dockerfile runs `prisma migrate deploy`).
- Rotate JWT secrets in Render if leaked; redeploy.
- To wake a sleeping free API before a demo, hit `/api/v1/health` once and wait ~30–60s.
