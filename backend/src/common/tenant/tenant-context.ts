import { AsyncLocalStorage } from 'async_hooks';
import { ShopRole } from '@prisma/client';

export type TenantStore = {
  userId: string;
  email: string | null;
  isPlatformAdmin: boolean;
  shopId?: string;
  shopRole?: ShopRole;
  shopStatus?: string;
};

export const tenantStorage = new AsyncLocalStorage<TenantStore>();

export function getTenantContext(): TenantStore | undefined {
  return tenantStorage.getStore();
}

export function requireTenantContext(): TenantStore {
  const ctx = tenantStorage.getStore();
  if (!ctx?.userId) {
    throw new Error('TENANT_CONTEXT_MISSING');
  }
  return ctx;
}

export function requireShopContext(): TenantStore & { shopId: string } {
  const ctx = requireTenantContext();
  if (!ctx.shopId) {
    throw Object.assign(new Error('SHOP_CONTEXT_REQUIRED'), {
      code: 'SHOP_CONTEXT_REQUIRED',
    });
  }
  return ctx as TenantStore & { shopId: string };
}
