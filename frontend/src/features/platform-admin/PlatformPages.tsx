import { useEffect, useState, type FormEvent } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { api } from '../../core/api/client';
import { getApiErrorMessage } from '../../core/api/errors';
import { useAuthStore } from '../../core/auth/auth-store';
import { brand } from '../../core/config/brand';
import { toastError } from '../../core/ui/toast';

export function PlatformLoginPage() {
  const { t } = useTranslation();
  const login = useAuthStore((s) => s.login);
  const navigate = useNavigate();
  const [email, setEmail] = useState('admin@silaisetu.com');
  const [password, setPassword] = useState('SilaiSetu_Admin_2026!');
  const [error, setError] = useState('');

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    setError('');
    try {
      const user = await login(email, password);
      if (!user.isPlatformAdmin) {
        const msg = 'Platform administrator access required';
        setError(msg);
        toastError(msg, t('auth.platformLogin'));
        return;
      }
      navigate('/platform-admin');
    } catch (err) {
      const msg = getApiErrorMessage(err, t('common.error'));
      setError(msg);
      toastError(msg, t('auth.platformLogin'));
    }
  }

  return (
    <div className="auth-page">
      <form className="auth-card" onSubmit={onSubmit}>
        <div className="muted">{brand.name} · Platform</div>
        <h1>{t('auth.platformLogin')}</h1>
        <div className="field">
          <label>{t('auth.email')}</label>
          <input className="input" value={email} onChange={(e) => setEmail(e.target.value)} />
        </div>
        <div className="field">
          <label>{t('auth.password')}</label>
          <input className="input" type="password" value={password} onChange={(e) => setPassword(e.target.value)} />
        </div>
        {error && <p className="error-text">{error}</p>}
        <button className="btn" style={{ width: '100%' }}>{t('auth.login')}</button>
      </form>
    </div>
  );
}

export function PlatformDashboardPage() {
  const { t } = useTranslation();
  const [data, setData] = useState<{
    totals: Record<string, number>;
    recentShops: Array<{ id: string; name: string; status: string; createdAt: string }>;
    recentEvents: Array<{ id: string; action: string; createdAt: string }>;
  } | null>(null);
  const [error, setError] = useState('');

  useEffect(() => {
    api.get('/platform-admin/dashboard')
      .then((r) => setData(r.data))
      .catch(() => setError(t('common.error')));
  }, [t]);

  if (error) return <div className="state-box">{error}</div>;
  if (!data) return <div className="state-box">{t('common.loading')}</div>;

  return (
    <div>
      <div className="page-header"><h1>{t('platform.dashboard')}</h1></div>
      <div className="stat-grid">
        <div className="stat"><div className="label">Shops</div><div className="value">{data.totals.shops}</div></div>
        <div className="stat"><div className="label">Active</div><div className="value">{data.totals.activeShops}</div></div>
        <div className="stat"><div className="label">Suspended</div><div className="value">{data.totals.suspendedShops}</div></div>
        <div className="stat"><div className="label">Users</div><div className="value">{data.totals.users}</div></div>
      </div>
      <div className="panel">
        <h2>Recent shops</h2>
        <div className="table-wrap">
          <table>
            <thead><tr><th>Name</th><th>Status</th><th>Created</th></tr></thead>
            <tbody>
              {data.recentShops.map((s) => (
                <tr key={s.id}>
                  <td><Link to={`/platform-admin/shops/${s.id}`}>{s.name}</Link></td>
                  <td><span className="badge">{s.status}</span></td>
                  <td>{new Date(s.createdAt).toLocaleString()}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

export function PlatformShopsPage() {
  const { t } = useTranslation();
  const [items, setItems] = useState<Array<{ id: string; name: string; status: string; city?: string }>>([]);
  const [search, setSearch] = useState('');
  const [status, setStatus] = useState('');

  async function load() {
    const { data } = await api.get('/platform-admin/shops', {
      params: { search: search || undefined, status: status || undefined },
    });
    setItems(data.items || []);
  }

  useEffect(() => { void load(); }, []);

  return (
    <div>
      <div className="page-header">
        <h1>{t('platform.shops')}</h1>
        <div className="toolbar">
          <input className="input" style={{ width: 200 }} value={search} onChange={(e) => setSearch(e.target.value)} placeholder={t('common.search')} />
          <select className="select" style={{ width: 160 }} value={status} onChange={(e) => setStatus(e.target.value)}>
            <option value="">All</option>
            <option value="ACTIVE">ACTIVE</option>
            <option value="SUSPENDED">SUSPENDED</option>
            <option value="PENDING">PENDING</option>
          </select>
          <button className="btn" type="button" onClick={() => void load()}>{t('common.search')}</button>
        </div>
      </div>
      <div className="panel table-wrap">
        <table>
          <thead><tr><th>Name</th><th>City</th><th>Status</th></tr></thead>
          <tbody>
            {items.map((s) => (
              <tr key={s.id}>
                <td><Link to={`/platform-admin/shops/${s.id}`}>{s.name}</Link></td>
                <td>{s.city || '—'}</td>
                <td><span className="badge">{s.status}</span></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

export function PlatformShopDetailPage() {
  const { id } = useParams();
  const { t } = useTranslation();
  const [shop, setShop] = useState<{
    id: string;
    name: string;
    status: string;
    statusHistory: Array<{ id: string; toStatus: string; reason?: string; createdAt: string }>;
    _count: { customers: number; orders: number };
  } | null>(null);
  const [reason, setReason] = useState('');

  async function load() {
    const { data } = await api.get(`/platform-admin/shops/${id}`);
    setShop(data);
  }

  useEffect(() => { void load(); }, [id]);

  async function setStatus(status: 'ACTIVE' | 'SUSPENDED') {
    await api.patch(`/platform-admin/shops/${id}/status`, { status, reason });
    setReason('');
    await load();
  }

  if (!shop) return <div className="state-box">{t('common.loading')}</div>;

  return (
    <div>
      <div className="page-header">
        <h1>{shop.name}</h1>
        <span className="badge">{shop.status}</span>
      </div>
      <div className="stat-grid">
        <div className="stat"><div className="label">Customers</div><div className="value">{shop._count.customers}</div></div>
        <div className="stat"><div className="label">Orders</div><div className="value">{shop._count.orders}</div></div>
      </div>
      <div className="panel" style={{ marginBottom: 16 }}>
        <div className="field">
          <label>{t('platform.reason')}</label>
          <input className="input" value={reason} onChange={(e) => setReason(e.target.value)} />
        </div>
        <div className="toolbar">
          <button className="btn danger" type="button" onClick={() => void setStatus('SUSPENDED')}>{t('platform.suspend')}</button>
          <button className="btn" type="button" onClick={() => void setStatus('ACTIVE')}>{t('platform.activate')}</button>
        </div>
      </div>
      <div className="panel">
        <h2>Status history</h2>
        <div className="table-wrap">
          <table>
            <thead><tr><th>Status</th><th>Reason</th><th>When</th></tr></thead>
            <tbody>
              {shop.statusHistory.map((h) => (
                <tr key={h.id}>
                  <td>{h.toStatus}</td>
                  <td>{h.reason || '—'}</td>
                  <td>{new Date(h.createdAt).toLocaleString()}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

export function PlatformUsersPage() {
  const { t } = useTranslation();
  const [items, setItems] = useState<Array<{ id: string; fullName: string; email: string; isActive: boolean; memberships: unknown[] }>>([]);
  useEffect(() => {
    api.get('/platform-admin/users').then((r) => setItems(r.data.items || []));
  }, []);
  return (
    <div>
      <div className="page-header"><h1>{t('platform.users')}</h1></div>
      <div className="panel table-wrap">
        <table>
          <thead><tr><th>Name</th><th>Email</th><th>Memberships</th><th>Active</th></tr></thead>
          <tbody>
            {items.map((u) => (
              <tr key={u.id}>
                <td>{u.fullName}</td>
                <td>{u.email}</td>
                <td>{u.memberships?.length ?? 0}</td>
                <td>{u.isActive ? 'yes' : 'no'}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

export function PlatformAuditPage() {
  const { t } = useTranslation();
  const [items, setItems] = useState<Array<{ id: string; action: string; reason?: string; createdAt: string; actor?: { fullName: string } }>>([]);
  useEffect(() => {
    api.get('/platform-admin/audit-logs').then((r) => setItems(r.data.items || []));
  }, []);
  return (
    <div>
      <div className="page-header"><h1>{t('platform.audit')}</h1></div>
      <div className="panel table-wrap">
        <table>
          <thead><tr><th>Action</th><th>Actor</th><th>Reason</th><th>When</th></tr></thead>
          <tbody>
            {items.map((a) => (
              <tr key={a.id}>
                <td>{a.action}</td>
                <td>{a.actor?.fullName || '—'}</td>
                <td>{a.reason || '—'}</td>
                <td>{new Date(a.createdAt).toLocaleString()}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

export function PlatformSettingsPage() {
  const { t } = useTranslation();
  const [items, setItems] = useState<Array<{ key: string; value: unknown }>>([]);
  useEffect(() => {
    api.get('/platform-admin/settings').then((r) => setItems(r.data || []));
  }, []);
  return (
    <div>
      <div className="page-header"><h1>{t('platform.settings')}</h1></div>
      <div className="panel">
        {!items.length ? <div className="state-box">{t('common.empty')}</div> : (
          <ul>{items.map((s) => <li key={s.key}><strong>{s.key}</strong>: {JSON.stringify(s.value)}</li>)}</ul>
        )}
      </div>
    </div>
  );
}

export function PlatformHealthPage() {
  const { t } = useTranslation();
  const [health, setHealth] = useState<Record<string, string> | null>(null);
  useEffect(() => {
    api.get('/platform-admin/system-health').then((r) => setHealth(r.data));
  }, []);
  if (!health) return <div className="state-box">{t('common.loading')}</div>;
  return (
    <div>
      <div className="page-header"><h1>{t('platform.health')}</h1></div>
      <div className="stat-grid">
        {Object.entries(health).map(([k, v]) => (
          <div className="stat" key={k}>
            <div className="label">{k}</div>
            <div className="value" style={{ fontSize: '1.1rem' }}>{String(v)}</div>
          </div>
        ))}
      </div>
    </div>
  );
}
