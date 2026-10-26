import axios from 'axios';

const baseURL = import.meta.env.VITE_API_URL || 'http://localhost:3000/api/v1';

export const api = axios.create({
  baseURL,
  withCredentials: true,
  headers: { 'Content-Type': 'application/json' },
});

let accessToken: string | null = sessionStorage.getItem('ss_access');
let shopId: string | null = localStorage.getItem('ss_shop');

export function setAccessToken(token: string | null) {
  accessToken = token;
  if (token) sessionStorage.setItem('ss_access', token);
  else sessionStorage.removeItem('ss_access');
}

export function setShopId(id: string | null) {
  shopId = id;
  if (id) localStorage.setItem('ss_shop', id);
  else localStorage.removeItem('ss_shop');
}

export function getShopId() {
  return shopId;
}

api.interceptors.request.use((config) => {
  if (accessToken) config.headers.Authorization = `Bearer ${accessToken}`;
  if (shopId) config.headers['X-Shop-Id'] = shopId;
  return config;
});

api.interceptors.response.use(
  (r) => r,
  async (error) => {
    const original = error.config;
    if (error.response?.status === 401 && !original._retry && !original.url?.includes('/auth/login')) {
      original._retry = true;
      try {
        const refresh = sessionStorage.getItem('ss_refresh');
        const { data } = await axios.post(`${baseURL}/auth/refresh`, {
          refreshToken: refresh,
        }, { withCredentials: true });
        setAccessToken(data.accessToken);
        if (data.refreshToken) sessionStorage.setItem('ss_refresh', data.refreshToken);
        original.headers.Authorization = `Bearer ${data.accessToken}`;
        return api(original);
      } catch {
        setAccessToken(null);
        sessionStorage.removeItem('ss_refresh');
      }
    }
    return Promise.reject(error);
  },
);
