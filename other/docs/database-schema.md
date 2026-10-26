# Database schema — SilaiSetu

Prisma schema: `backend/prisma/schema.prisma`  
Migrations: `backend/prisma/migrations/`

## Core tables

| Table | Purpose |
|-------|---------|
| `users` | Global accounts |
| `platform_admins` | Platform-only admin link |
| `refresh_tokens` | Hashed refresh tokens |
| `shops` | Tenants |
| `shop_memberships` | User↔shop roles |
| `shop_settings` | Shop preferences |
| `shop_status_history` | Activate/suspend audit trail |
| `customers` | Shop-scoped customers |
| `garment_templates` | Configurable measurement field JSON |
| `measurement_records` | Versioned measurements |
| `stitching_orders` | Orders + balances |
| `order_items` | Line items + measurement snapshots |
| `order_status_history` | Status transitions |
| `payments` | Advances/partials/finals/reversals + idempotency |
| `notifications` | In-app notifications |
| `audit_logs` | Platform audit events |
| `platform_settings` | Non-secret platform config |

## JSONB columns

- `garment_templates.fields` — field definitions (validated in NestJS)
- `measurement_records.values` — field id → value map
- `order_items.measurementSnapshot` — immutable order-time copy
- `shops.workingHours` / `preferences` — shop config bags

## Indexes

Tenant-scoped indexes on `(shopId, …)` for customers, orders, payments, templates.
