# Authentication providers (email / SMS)

SilaiSetu auth supports email and mobile identifiers, password reset, and verification OTPs. Delivery depends on optional providers. Without them, local development still works; production must not pretend messages were delivered.

## Environment variables

| Variable | Purpose |
| --- | --- |
| `SMTP_URL` | Email delivery for reset links / verification |
| `SMS_PROVIDER_API_KEY` | SMS provider API key for OTP / reset |
| `AUTH_DEV_EXPOSE_CODES` | When `true` (local only), API may return `devHint` with token/OTP |
| `AUTH_REQUIRE_VERIFICATION` | When `true`, unverified accounts must complete verification before full access |

See `backend/.env.example`.

## Local development mode

Recommended local values:

```env
AUTH_DEV_EXPOSE_CODES=true
AUTH_REQUIRE_VERIFICATION=false
# SMTP_URL=
# SMS_PROVIDER_API_KEY=
```

Behavior:

- Registration and login work with email or `+91` mobile numbers.
- Forgot-password and verify endpoints create secure hashed tokens in the database.
- If SMTP/SMS are unset, the API logs that delivery is queued/skipped and may include a `devHint` only when `AUTH_DEV_EXPOSE_CODES=true`.
- The Flutter app shows the dev hint on Forgot Password / Verify screens for local testing.
- Generic responses are used so account existence is not leaked to unauthenticated callers.

## Production

```env
AUTH_DEV_EXPOSE_CODES=false
AUTH_REQUIRE_VERIFICATION=true
SMTP_URL=smtps://user:pass@smtp.example.com:465
SMS_PROVIDER_API_KEY=...
```

Never commit real SMTP or SMS secrets. Do not enable `AUTH_DEV_EXPOSE_CODES` in production.

## Flutter deep links

Reset-password deep links can open `/reset-password` with a token argument. Until app links are configured for your domains, paste the token from email/SMS (or `devHint` in local mode) into the Reset Password screen.
