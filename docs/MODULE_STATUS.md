# SilaiSetu module status

Generated for the complete tailor-shop management build.

## Running locally

| Service | URL |
| --- | --- |
| API | http://localhost:3000/api/v1 |
| Swagger | http://localhost:3000/docs |
| Web | http://localhost:5173 |
| Prisma Studio | http://localhost:5555 |
| Flutter (device) | `cd app && flutter run -d <device> --dart-define=API_HOST=<LAN_IP>` |

**Production (free):** see [`PRODUCTION_DEPLOY.md`](PRODUCTION_DEPLOY.md) — GitHub → Neon → Render → Cloudflare Pages (no Android upload).

Auth/email-SMS notes: see `docs/AUTH_PROVIDERS.md`.

## Completed (mobile + existing API)

| Module | Status |
| --- | --- |
| Auth / onboarding / sessions | Working |
| Navigation: Dashboard · Total · Pending · Customers · More | Working |
| Dashboard (reports summary + calendar + quick actions) | Working |
| Customers CRUD, archive/restore, dialer, detail | Working |
| Orders create / list / detail / status workflow / cancel | Working |
| Customer payments + receipt view | Working |
| Client PDF invoice (preview/share via `pdf` + `share_plus`) | Working |
| WhatsApp share (order / receipt / customer via `wa.me`) | Working |
| Delivery reminders (daily cron → in-app `DELIVERY_REMINDER` / `OVERDUE`; tap opens order) | Working (in-app only; not FCM/SMS) |
| Friendly API errors (`SsSnack` / `ssErrorMessage`) | Working |
| Measurements create/list (versioned) | Working |
| Garment templates list + seed helpers | Working |
| Staff invite / list / deactivate | Working |
| Calendar (trial/delivery agenda) | Working |
| Reports summary | Working |
| In-app notifications read/mark | Working |
| Shop profile / personal profile / settings / l10n | Working |

## Incomplete (UI placeholder — backend missing)

| Module | Gap |
| --- | --- |
| Tasks & production board | No task tables/APIs (only `assignedToId` on orders) |
| Worker payments | No worker ledger |
| Expenses | No expense APIs |
| Inventory / stock movements | No inventory models |
| Stitch gallery | No media gallery APIs |
| GST / tax on invoice | Tax fields exist on shop settings; PDF does not compute GST yet |
| Offline sync / conflict UI | Not implemented beyond error/retry |
| Push / SMS delivery reminders | In-app notifications only |

## Next backend migrations (recommended)

1. `ProductionTask` + assignment history  
2. `WorkerPayment` ledger  
3. `Expense`  
4. `InventoryItem` + `StockMovement`  
5. `GalleryItem` + image storage strategy  

Do not mark those mobile modules complete until the corresponding APIs exist and the acceptance workflow passes end to end.

## Acceptance notes (this sprint)

1. Order with customer phone → WhatsApp opens with order summary.  
2. Receipt / order detail → PDF preview + share (WhatsApp/Files).  
3. Cron (`30 2 * * *` UTC) or `POST /notifications/run-delivery-reminders` → OWNER/MANAGER see today/overdue notifications; tap opens `/orders/:id`.  
4. Offline / 400 → floating snackbar (no raw Dio JSON).
