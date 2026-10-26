# Security & tenant isolation

## Layers

1. **Authentication** — JWT access + hashed refresh tokens.
2. **Authorization** — shop role guards + platform admin guard.
3. **Tenant context** — `X-Shop-Id` must match a membership in the token; live shop status loaded from DB (suspension immediate).
4. **Query filters** — every shop query includes `shopId` from server context.
5. **RLS (optional hardening)** — `backend/prisma/sql/rls.sql` with `FORCE ROW LEVEL SECURITY` and `app.current_shop_id` session GUC.

## Current limitation

Local development uses the Prisma migration role (table owner), which **bypasses RLS**. NestJS filters remain the primary enforcement. Before production:

1. Grant DML to `silaisetu_app` only.
2. Apply `rls.sql`.
3. Set `SET LOCAL app.current_shop_id` per transaction via Prisma middleware / interactive transactions.
4. Point `DATABASE_URL` at the non-owner role.

## Shop suspension

Suspended shops receive `403 SHOP_SUSPENDED` on shop-scoped operations. Platform admin routes remain available to platform admins.

## Platform vs shop

Shop OWNER cannot access `/platform-admin/*`. Platform admin bootstrap only via seed env vars — no self-promotion API.

## Secrets

Never commit real production secrets. `.env` is gitignored; use `.env.example` placeholders.
