import { ShopRole } from '@prisma/client';

export type JwtMembership = {
  shopId: string;
  role: ShopRole;
  status: string;
};

export type JwtPayload = {
  sub: string;
  email: string | null;
  isPlatformAdmin: boolean;
  memberships: JwtMembership[];
};
