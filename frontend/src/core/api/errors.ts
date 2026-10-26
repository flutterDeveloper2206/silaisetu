import axios from 'axios';

/** Friendly message from Nest `{ code, message }` or Axios/network failures. */
export function getApiErrorMessage(
  error: unknown,
  fallback = 'Something went wrong',
): string {
  if (axios.isAxiosError(error)) {
    const data = error.response?.data as
      | { message?: string | string[]; code?: string }
      | undefined;
    if (data) {
      if (Array.isArray(data.message) && data.message.length) {
        return data.message.map(String).filter(Boolean).join('\n');
      }
      if (typeof data.message === 'string' && data.message.trim()) {
        return data.message.trim();
      }
    }
    if (!error.response) {
      return 'No internet connection. Please try again.';
    }
    if (error.response.status === 401 && !data?.message) {
      return 'Invalid email/mobile number or password';
    }
  }
  if (error instanceof Error && error.message && !error.message.startsWith('Axios')) {
    return error.message;
  }
  return fallback;
}
