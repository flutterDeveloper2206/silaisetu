import { OrderStatus } from '@prisma/client';
import { canTransition } from './order-status';

describe('order status transitions', () => {
  it('allows NEW -> CUTTING', () => {
    expect(canTransition(OrderStatus.NEW, OrderStatus.CUTTING)).toBe(true);
  });

  it('rejects NEW -> DELIVERED', () => {
    expect(canTransition(OrderStatus.NEW, OrderStatus.DELIVERED)).toBe(false);
  });

  it('rejects transitions from DELIVERED', () => {
    expect(canTransition(OrderStatus.DELIVERED, OrderStatus.READY)).toBe(false);
  });

  it('allows READY -> DELIVERED', () => {
    expect(canTransition(OrderStatus.READY, OrderStatus.DELIVERED)).toBe(true);
  });

  it('allows STITCHING -> TRIAL', () => {
    expect(canTransition(OrderStatus.STITCHING, OrderStatus.TRIAL)).toBe(true);
  });
});
