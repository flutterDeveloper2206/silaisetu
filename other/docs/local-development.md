# Local development

## Start order

1. PostgreSQL (Homebrew or Docker)
2. Backend migrate + seed + `npm run start:dev`
3. Frontend `npm run dev`
4. Flutter `flutter run`

## Useful commands

```bash
# Backend
cd backend && npm run prisma:migrate && npm run prisma:seed && npm run start:dev

# Frontend
cd frontend && npm run dev

# Flutter
cd app && flutter pub get && flutter gen-l10n && flutter run

# Unit test (order transitions)
cd backend && npx jest src/modules/orders/order-status.spec.ts
```

## Platform admin bootstrap

Set in `backend/.env` before seed:

```env
PLATFORM_ADMIN_EMAIL=admin@silaisetu.local
PLATFORM_ADMIN_PASSWORD=ChangeMe_Admin_123!
```

Then `npm run prisma:seed` (or `npm run bootstrap:admin`).

## Shutdown

- Stop Nest/Vite/Flutter processes (Ctrl+C)
- Docker: `cd other && docker compose down` (data volume retained unless `-v`)
