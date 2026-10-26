import { useEffect, useState, type ReactNode } from 'react';
import { useTranslation } from 'react-i18next';
import { api } from '../../core/api/client';

function ListPage({
  titleKey,
  loader,
  columns,
  renderRow,
}: {
  titleKey: string;
  loader: () => Promise<unknown[]>;
  columns: string[];
  renderRow: (item: Record<string, unknown>) => ReactNode;
}) {
  const { t } = useTranslation();
  const [items, setItems] = useState<unknown[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    setLoading(true);
    loader()
      .then(setItems)
      .catch(() => setError(t('common.error')))
      .finally(() => setLoading(false));
  }, []);

  return (
    <div>
      <div className="page-header"><h1>{t(titleKey)}</h1></div>
      {loading && <div className="state-box">{t('common.loading')}</div>}
      {error && <div className="state-box">{error}</div>}
      {!loading && !error && !items.length && <div className="state-box">{t('common.empty')}</div>}
      {!loading && !!items.length && (
        <div className="panel table-wrap">
          <table>
            <thead><tr>{columns.map((c) => <th key={c}>{c}</th>)}</tr></thead>
            <tbody>{items.map((item, i) => <tr key={i}>{renderRow(item as Record<string, unknown>)}</tr>)}</tbody>
          </table>
        </div>
      )}
    </div>
  );
}

export function TemplatesPage() {
  return (
    <ListPage
      titleKey="nav.templates"
      loader={async () => (await api.get('/garment-templates')).data}
      columns={['Name', 'Code', 'Version']}
      renderRow={(row) => (
        <>
          <td>{String(row.name)}</td>
          <td>{String(row.code)}</td>
          <td>{String(row.version)}</td>
        </>
      )}
    />
  );
}

export function CalendarPage() {
  const { t } = useTranslation();
  const [orders, setOrders] = useState<Array<{ orderNumber: string; status: string; deliveryDate?: string; customer: { fullName: string } }>>([]);
  useEffect(() => {
    const from = new Date(); from.setDate(1);
    const to = new Date(from.getFullYear(), from.getMonth() + 1, 0);
    api.get('/calendar', { params: { from: from.toISOString().slice(0, 10), to: to.toISOString().slice(0, 10) } })
      .then((r) => setOrders(r.data.orders || []));
  }, []);
  return (
    <div>
      <div className="page-header"><h1>{t('nav.calendar')}</h1></div>
      <div className="panel table-wrap">
        <table>
          <thead><tr><th>#</th><th>Customer</th><th>Status</th><th>Delivery</th></tr></thead>
          <tbody>
            {orders.map((o, i) => (
              <tr key={i}>
                <td>{o.orderNumber}</td>
                <td>{o.customer.fullName}</td>
                <td>{o.status}</td>
                <td>{o.deliveryDate ? new Date(o.deliveryDate).toLocaleDateString() : '—'}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

export function ReportsPage() {
  const { t } = useTranslation();
  const [summary, setSummary] = useState<Record<string, unknown> | null>(null);
  useEffect(() => {
    api.get('/reports/summary').then((r) => setSummary(r.data));
  }, []);
  if (!summary) return <div className="state-box">{t('common.loading')}</div>;
  return (
    <div>
      <div className="page-header"><h1>{t('nav.reports')}</h1></div>
      <div className="stat-grid">
        <div className="stat"><div className="label">Orders</div><div className="value">{String(summary.ordersCount)}</div></div>
        <div className="stat"><div className="label">Order value</div><div className="value" style={{ fontSize: '1.2rem' }}>₹{Number(summary.orderValue || 0).toLocaleString('en-IN')}</div></div>
        <div className="stat"><div className="label">Received</div><div className="value" style={{ fontSize: '1.2rem' }}>₹{Number(summary.revenueReceived || 0).toLocaleString('en-IN')}</div></div>
        <div className="stat"><div className="label">Outstanding</div><div className="value" style={{ fontSize: '1.2rem' }}>₹{Number(summary.outstandingBalance || 0).toLocaleString('en-IN')}</div></div>
      </div>
      <p className="muted">{String(summary.note || '')}</p>
    </div>
  );
}

export function StaffPage() {
  return (
    <ListPage
      titleKey="nav.staff"
      loader={async () => (await api.get('/staff')).data}
      columns={['Name', 'Email', 'Role', 'Active']}
      renderRow={(row) => {
        const user = row.user as { fullName: string; email: string };
        return (
          <>
            <td>{user.fullName}</td>
            <td>{user.email}</td>
            <td>{String(row.role)}</td>
            <td>{row.isActive ? 'yes' : 'no'}</td>
          </>
        );
      }}
    />
  );
}
