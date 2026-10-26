/** Normalize phone numbers. Default country calling code 91 (India), extensible. */
export function normalizePhone(
  raw: string,
  defaultCountryCode = '91',
): string | null {
  const digits = raw.replace(/[^\d+]/g, '');
  if (!digits) return null;
  let n = digits.startsWith('+') ? digits.slice(1) : digits;
  n = n.replace(/\D/g, '');
  if (n.length === 10) n = `${defaultCountryCode}${n}`;
  if (n.length < 10 || n.length > 15) return null;
  return `+${n}`;
}

export function looksLikeEmail(value: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value.trim());
}

export function resolveIdentifier(identifier: string): {
  type: 'email' | 'phone';
  value: string;
} | null {
  const v = identifier.trim();
  if (!v) return null;
  if (looksLikeEmail(v)) {
    return { type: 'email', value: v.toLowerCase() };
  }
  const phone = normalizePhone(v);
  if (phone) return { type: 'phone', value: phone };
  return null;
}
