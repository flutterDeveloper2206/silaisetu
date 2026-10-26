# SilaiSetu — Your Tailoring Business, Connected.

Multi-tenant tailor management system for Indian stitching shops: Flutter mobile app, React shop dashboard + platform admin portal, NestJS API, PostgreSQL.

**Provisional brand name.** Trademark, app-store name, and domain availability still need verification before commercial launch.

> Hosting / cloud deployment and subscription billing are **out of scope** for this version (local development only).

---

## Folder structure

```text
tailor/
├── app/          # Flutter (Android / iOS) — GetX
├── frontend/     # React + Vite — shop dashboard + /platform-admin
├── backend/      # NestJS REST API (/api/v1) + Prisma
└── other/        # Docker Compose, docs, scripts
```

---

## Prerequisites

- Node.js 20+
- Flutter SDK 3.9+
- PostgreSQL 16+ (Homebrew local DB used by default)
- Optional: Docker / Colima for Compose Postgres (`other/docker-compose.yml`)

---

## Local PostgreSQL

### Option A — Homebrew Postgres (verified in this environment)

```bash
psql -d postgres -c "CREATE USER silaisetu WITH PASSWORD 'silaisetu_dev_only' CREATEDB;"
psql -d postgres -c "CREATE DATABASE silaisetu OWNER silaisetu;"
```

Connection string:

```text
postgresql://silaisetu:silaisetu_dev_only@localhost:5432/silaisetu?schema=public
```

### Option B — Docker Compose

```bash
cd other
docker compose up -d   # requires Docker Compose plugin + running engine
```

Colima was not running during setup; use Homebrew Postgres if Compose is unavailable.

---

## Backend

```bash
cd backend
cp .env.example .env   # already safe local defaults for development
npm install
npm run prisma:generate
npm run prisma:migrate
npm run prisma:seed
npm run start:dev
```

- API: http://localhost:3000/api/v1  
- Swagger: http://localhost:3000/docs  
- Health: http://localhost:3000/api/v1/health  

### Seeded accounts

| Role | Email | Password |
|------|-------|----------|
| Platform admin | `admin@silaisetu.local` | `ChangeMe_Admin_123!` |
| Shop owner (Ahmedabad) | `owner1@silaisetu.local` | `OwnerDemo_123!` |
| Shop owner (Surat) | `owner2@silaisetu.local` | `OwnerDemo_123!` |

Override admin via `PLATFORM_ADMIN_EMAIL` / `PLATFORM_ADMIN_PASSWORD` in `.env` before seeding.

### Tests

```bash
cd backend
npx jest src/modules/orders/order-status.spec.ts
```

---

## React frontend

```bash
cd frontend
cp .env.example .env
npm install
npm run dev      # http://localhost:5173
npm run build
```

- Shop app: `/login` → `/app/*`  
- Platform admin: `/platform-admin/login` → `/platform-admin/*`  

Send shop context with header `X-Shop-Id` (selected automatically after login).

---

## Flutter app

```bash
cd app
flutter pub get
flutter gen-l10n
flutter run
```

API base URL: `http://10.0.2.2:3000/api/v1` on Android emulator, `http://localhost:3000/api/v1` on iOS simulator / desktop.

Languages: Gujarati, Hindi, English. Themes: light / dark / system.

---

## Documentation

| Doc | Path |
|-----|------|
| Architecture | `other/docs/architecture.md` |
| Database schema | `other/docs/database-schema.md` |
| API overview | `other/docs/api.md` |
| Security & tenant isolation | `other/docs/security-and-tenant-isolation.md` |
| Local development | `other/docs/local-development.md` |
| Competitor analysis | `other/docs/competitor-analysis.md` |
| Future subscriptions | `other/docs/future-subscriptions.md` |

---

## Current limitations

- RLS SQL is provided (`backend/prisma/sql/rls.sql`) but local runtime still uses the Prisma owner role + NestJS tenant filters; wire `silaisetu_app` + `SET LOCAL` before production-like hardening.
- Flutter covers login, dashboard, customers, orders, settings, onboarding; web covers broader shop + platform admin surfaces.
- WhatsApp / SMS delivery not implemented (in-app notifications scaffold only).
- No cloud hosting, no subscription billing.
- PDF receipts are deferred; payment receipt JSON + CSV order export exist.

---

## Troubleshooting

- **API connection refused:** ensure `npm run start:dev` in `backend/` and Postgres is accepting connections (`pg_isready`).
- **Login works but customers 403 SHOP_SUSPENDED:** shop was suspended by platform admin — reactivate from `/platform-admin/shops/:id`.
- **Cross-shop data missing:** wrong `X-Shop-Id` or membership — call `/auth/me` and select a membership shop id.
# silaisetu
