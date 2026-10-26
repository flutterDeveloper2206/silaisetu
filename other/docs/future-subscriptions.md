# Future Subscriptions Architecture (Planned — Not Implemented)

SilaiSetu v1 intentionally **does not** implement subscription billing, checkout, payment gateways, renewals, invoices, or entitlement enforcement.

Shop activation / suspension by platform admins is **independent** of any future payment status.

---

## Design principles for a later version

1. Keep `Shop` / tenant identity independent from subscription records.
2. Do not gate JWT authentication on subscription state.
3. Use entitlements as an additive authorization layer after auth + tenant membership.
4. Platform admins can activate/suspend shops regardless of billing state.
5. Never mix “suspended for abuse” with “past due on invoice” without clear distinct fields.

---

## Planned concepts (not in schema today)

| Concept | Purpose |
|---|---|
| `Plan` | Named commercial plan (e.g. Starter, Growth) with limits metadata |
| `Subscription` | Shop ↔ Plan link with period start/end, status |
| `Entitlement` | Feature flags / quotas derived from plan (max staff, max orders/month) |
| `Invoice` | Billing period charges |
| `BillingEvent` | Webhook/normalized events from provider |
| `PaymentProviderCustomer` | External customer id mapping |

Statuses might include: `TRIALING`, `ACTIVE`, `PAST_DUE`, `CANCELLED` — **planned only**.

---

## Integration with current tenant model

```
User → ShopMembership → Shop (tenant)
                         ↓ (future)
                    Subscription → Plan → Entitlements
```

Runtime checks (future):

1. Authenticate user.
2. Resolve membership + shop status (`ACTIVE` / `SUSPENDED`).
3. Optionally resolve subscription entitlements for feature limits.
4. Enforce RLS + service-level tenant filters as today.

---

## Explicitly out of scope for v1

- Paid plans, checkout, gateways, recurring billing, subscription invoices, retries, cancellation automation, subscription-based feature locks, fake billing screens.
