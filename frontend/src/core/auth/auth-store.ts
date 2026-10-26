import { create } from 'zustand';
import { api, setAccessToken, setShopId } from '../api/client';

export type Membership = {
  id: string;
  role: 'OWNER' | 'MANAGER' | 'TAILOR';
  shop: {
    id: string;
    name: string;
    slug: string;
    status: string;
    defaultLanguage?: string;
    measurementUnit?: string;
  };
};

export type User = {
  id: string;
  email: string;
  fullName: string;
  isPlatformAdmin?: boolean;
  languagePref?: string;
  themePref?: string;
  memberships: Membership[];
};

type AuthState = {
  user: User | null;
  loading: boolean;
  setUser: (user: User | null) => void;
  login: (email: string, password: string) => Promise<User>;
  register: (payload: {
    email: string;
    password: string;
    fullName: string;
    phone?: string;
  }) => Promise<User>;
  logout: () => Promise<void>;
  hydrate: () => Promise<void>;
  selectShop: (shopId: string) => void;
};

export const useAuthStore = create<AuthState>((set, get) => ({
  user: null,
  loading: true,
  setUser: (user) => set({ user }),
  selectShop: (shopId) => {
    setShopId(shopId);
    set({ user: get().user });
  },
  login: async (email, password) => {
    const { data } = await api.post('/auth/login', {
      email: email.trim().toLowerCase(),
      password,
    });
    setAccessToken(data.accessToken);
    if (data.refreshToken) sessionStorage.setItem('ss_refresh', data.refreshToken);
    const shop = data.user.memberships?.[0]?.shop?.id;
    if (shop) setShopId(shop);
    set({ user: data.user });
    return data.user as User;
  },
  register: async (payload) => {
    const { data } = await api.post('/auth/register', payload);
    setAccessToken(data.accessToken);
    if (data.refreshToken) sessionStorage.setItem('ss_refresh', data.refreshToken);
    set({ user: data.user });
    return data.user as User;
  },
  logout: async () => {
    try {
      await api.post('/auth/logout', {
        refreshToken: sessionStorage.getItem('ss_refresh'),
      });
    } catch {
      /* ignore */
    }
    setAccessToken(null);
    setShopId(null);
    sessionStorage.removeItem('ss_refresh');
    set({ user: null });
  },
  hydrate: async () => {
    try {
      if (!sessionStorage.getItem('ss_access')) {
        set({ user: null, loading: false });
        return;
      }
      const { data } = await api.get('/auth/me');
      set({ user: data, loading: false });
      if (!localStorage.getItem('ss_shop') && data.memberships?.[0]?.shop?.id) {
        setShopId(data.memberships[0].shop.id);
      }
    } catch {
      set({ user: null, loading: false });
    }
  },
}));
