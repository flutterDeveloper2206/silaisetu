export type SubscriptionConfig = {
  enabled: boolean;
  trialDays: number;
  paidDays: number;
  amountInr: number;
  upiId: string;
  qrImageUrl: string;
  instructions: string;
};

export const SUBSCRIPTION_SETTING_KEYS = {
  enabled: 'subscription.enabled',
  trialDays: 'subscription.trialDays',
  paidDays: 'subscription.paidDays',
  amountInr: 'subscription.amountInr',
  upiId: 'subscription.upiId',
  qrImageUrl: 'subscription.qrImageUrl',
  instructions: 'subscription.instructions',
} as const;

export const DEFAULT_SUBSCRIPTION_CONFIG: SubscriptionConfig = {
  enabled: false,
  trialDays: 30,
  paidDays: 365,
  amountInr: 2999,
  upiId: '',
  qrImageUrl: '',
  instructions:
    'Pay via UPI using the QR code, then upload the payment screenshot and enter the UPI transaction ID.',
};

/** Unwrap PlatformSettings Json `{ v: ... }` or raw primitives. */
export function unwrapSettingValue(raw: unknown): unknown {
  if (raw && typeof raw === 'object' && !Array.isArray(raw) && 'v' in raw) {
    return (raw as { v: unknown }).v;
  }
  return raw;
}

export function wrapSettingValue(v: unknown): object {
  return { v };
}
