import { SetMetadata } from '@nestjs/common';
import { ShopRole } from '@prisma/client';

export const ROLES_KEY = 'shop_roles';
export const Roles = (...roles: ShopRole[]) => SetMetadata(ROLES_KEY, roles);

export const PLATFORM_ADMIN_KEY = 'platform_admin';
export const PlatformAdminOnly = () => SetMetadata(PLATFORM_ADMIN_KEY, true);

export const IS_PUBLIC_KEY = 'is_public';
export const Public = () => SetMetadata(IS_PUBLIC_KEY, true);
