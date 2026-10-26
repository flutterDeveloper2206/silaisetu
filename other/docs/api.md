# API overview — SilaiSetu

Base URL: `http://localhost:3000/api/v1`  
Swagger UI: `http://localhost:3000/docs`

Errors: `{ code, message, params?, statusCode }`

## Auth

| Method | Path | Notes |
|--------|------|-------|
| POST | `/auth/register` | Local auto-verify |
| POST | `/auth/login` | Returns access + refresh |
| POST | `/auth/refresh` | Body or cookie |
| POST | `/auth/logout` | Revokes refresh |
| GET/PATCH | `/auth/me` | Profile + memberships |

## Shop

| Method | Path |
|--------|------|
| POST | `/shops` |
| GET | `/shops/mine` |
| GET/PATCH | `/shops/:id` |
| GET/PATCH | `/shops/:id/settings` |

Header `X-Shop-Id` required for shop-scoped resources.

## Shop resources

- `/customers`, `/garment-templates`, `/measurements`, `/orders`, `/orders/:id/status`
- `/payments`, `/calendar`, `/reports/summary`, `/reports/orders.csv`, `/staff`, `/notifications`

## Platform admin

Prefix `/platform-admin/*` (platform JWT required):

- `/dashboard`, `/shops`, `/shops/:id`, `/shops/:id/status`
- `/users`, `/audit-logs`, `/settings`, `/system-health`

## Health

`GET /health` — public API + DB check.
