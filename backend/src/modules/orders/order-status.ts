import { OrderStatus } from '@prisma/client';

const ALLOWED: Record<OrderStatus, OrderStatus[]> = {
  NEW: [OrderStatus.CUTTING, OrderStatus.CANCELLED],
  CUTTING: [OrderStatus.STITCHING, OrderStatus.CANCELLED],
  STITCHING: [OrderStatus.TRIAL, OrderStatus.READY, OrderStatus.CANCELLED],
  TRIAL: [OrderStatus.STITCHING, OrderStatus.READY, OrderStatus.CANCELLED],
  READY: [OrderStatus.DELIVERED, OrderStatus.CANCELLED],
  DELIVERED: [],
  CANCELLED: [],
};

export function canTransition(from: OrderStatus, to: OrderStatus): boolean {
  return ALLOWED[from]?.includes(to) ?? false;
}

export { ALLOWED as ORDER_TRANSITIONS };
