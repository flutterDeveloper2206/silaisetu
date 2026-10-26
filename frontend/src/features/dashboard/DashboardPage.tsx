import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { api } from '../../core/api/client';

type CalendarRes = {
  summary: {
    todayDeliveries: number;
    overdue: number;
    byStatus: { status: string; _count: number }[];
  };
  orders: Array<{
    id: string;
    orderNumber: string;
    status: string;
    deliveryDate?: string;
    customer: { fullName: string };
  }>;
};

export function DashboardPage() {
  const { t } = useTranslation();
  const [data, setData] = useState<CalendarRes | null>(null);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(true);

  async function load() {
    setLoading(true);
    setError('');
    try {
      const from = new Date();
      from.setDate(1);
      const to = new Date(from.getFullYear(), from.getMonth() + 1, 0);
      const { data: res } = await api.get<CalendarRes>('/calendar', {
        params: {
          from: from.toISOString().slice(0, 10),
          to: to.toISOString().slice(0, 10),
        },
      });
      setData(res);
    } catch {
      setError(t('common.error'));
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    void load();
  }, []);

  if (loading) return <div className="state-box">{t('common.loading')}</div>;
  if (error) {
    return (
      <div className="state-box">
        <p>{error}</p>
        <button className="btn" type="button" onClick={() => void load()}>{t('common.retry')}</button>
      </div>
    );
  }

  return (
    <div>
      <div className="page-header">
        <h1>{t('dashboard.title')}</h1>
      </div>
      <div className="stat-grid">
        <div className="stat">
          <div className="label">{t('dashboard.todayDeliveries')}</div>
          <div className="value">{data?.summary.todayDeliveries ?? 0}</div>
        </div>
        <div className="stat">
          <div className="label">{t('dashboard.overdue')}</div>
          <div className="value">{data?.summary.overdue ?? 0}</div>
        </div>
        {(data?.summary.byStatus || []).map((s) => (
          <div className="stat" key={s.status}>
            <div className="label">{s.status}</div>
            <div className="value">{s._count}</div>
          </div>
        ))}
      </div>
      <div className="panel">
        <h2 style={{ marginTop: 0 }}>{t('dashboard.pipeline')}</h2>
        {!data?.orders.length ? (
          <div className="state-box">{t('common.empty')}</div>
        ) : (
          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>#</th>
                  <th>{t('customers.name')}</th>
                  <th>{t('orders.status')}</th>
                  <th>{t('orders.delivery')}</th>
                </tr>
              </thead>
              <tbody>
                {data.orders.slice(0, 15).map((o) => (
                  <tr key={o.id}>
                    <td>{o.orderNumber}</td>
                    <td>{o.customer.fullName}</td>
                    <td><span className="badge">{o.status}</span></td>
                    <td>{o.deliveryDate ? new Date(o.deliveryDate).toLocaleDateString() : '—'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
