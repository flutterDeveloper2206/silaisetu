# Architecture — SilaiSetu

## Overview

SilaiSetu is a **modular monolith**:

- `backend/` NestJS REST API (`/api/v1`) + Prisma + PostgreSQL
- `frontend/` React shop dashboard and separate platform admin portal
- `app/` Flutter mobile client (GetX)

Clients never talk to PostgreSQL directly.

## Tenancy

- A **Shop** is the tenant boundary.
- Users authenticate globally; shop access is via `ShopMembership` (OWNER / MANAGER / TAILOR).
- Active shop is selected with header `X-Shop-Id`, validated against JWT memberships on the server.
- Client-supplied tenant ids are never trusted alone.
- Platform admins are a separate `PlatformAdmin` identity — shop OWNER ≠ platform admin.

## Auth

- Access JWT (short-lived) + refresh token (hashed at rest).
- Refresh cookie (httpOnly) for web; mobile stores tokens in secure storage.
- Guards: JWT, shop roles, shop active/suspended, platform admin.

## Domain modules (backend)

auth, tenants/shops, customers, garment-templates, measurements, orders, payments, staff, reports, notifications, platform-admin, health.

## Money

PostgreSQL `NUMERIC` / Prisma `Decimal`. Order balances recalculated in transactions from payment events.

## Orders

Status machine: `NEW → CUTTING → STITCHING → TRIAL → READY → DELIVERED` (+ `CANCELLED` rules). Measurement snapshots stored on order items.

## Future

Subscriptions intentionally deferred — see `future-subscriptions.md`.
