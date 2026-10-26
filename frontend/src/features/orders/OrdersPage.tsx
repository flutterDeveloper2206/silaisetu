import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { api } from '../../core/api/client';

type Order = {
  id: string;
  orderNumber: string;
  status: string;
  totalAmount: string;
  balanceDue: string;
  deliveryDate?: string;
  customer: { fullName: string; phone: string };
};

const NEXT: Record<string, string | undefined> = {
  NEW: 'CUTTING',
  CUTTING: 'STITCHING',
  STITCHING: 'TRIAL',
  TRIAL: 'READY',
  READY: 'DELIVERED',
};

export function OrdersPage() {
  const { t } = useTranslation();
  const [items, setItems] = useState<Order[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  async function load() {
    setLoading(true);
    setError('');
    try {
      const { data } = await api.get('/orders');
      setItems(data.items || []);
    } catch {
      setError(t('common.error'));
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    void load();
  }, []);

  async function advance(order: Order) {
    const next = NEXT[order.status];
    if (!next) return;
    await api.patch(`/orders/${order.id}/status`, { status: next });
    await load();
  }

  if (loading) return <div className="state-box">{t('common.loading')}</div>;
  if (error) {
    return (
      <div className="state-box">
        <p>{error}</p>
        <button className="btn" onClick={() => void load()}>{t('common.retry')}</button>
      </div>
    );
  }

  return (
    <div>
      <div className="page-header">
        <h1>{t('orders.title')}</h1>
        <button className="btn secondary" type="button" onClick={() => void load()}>{t('common.retry')}</button>
      </div>
      {!items.length ? (
        <div className="state-box">{t('common.empty')}</div>
      ) : (
        <div className="panel table-wrap">
          <table>
            <thead>
              <tr>
                <th>#</th>
                <th>{t('customers.name')}</th>
                <th>{t('orders.status')}</th>
                <th>{t('orders.balance')}</th>
                <th>{t('orders.delivery')}</th>
                <th />
              </tr>
            </thead>
            <tbody>
              {items.map((o) => (
                <tr key={o.id}>
                  <td>{o.orderNumber}</td>
                  <td>{o.customer.fullName}</td>
                  <td><span className="badge">{o.status}</span></td>
                  <td>₹{Number(o.balanceDue).toLocaleString('en-IN')}</td>
                  <td>{o.deliveryDate ? new Date(o.deliveryDate).toLocaleDateString() : '—'}</td>
                  <td>
                    {NEXT[o.status] && (
                      <button type="button" className="btn secondary" onClick={() => void advance(o)}>
                        → {NEXT[o.status]}
                      </button>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
