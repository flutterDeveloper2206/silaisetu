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

type AdminShopRow = {
  id: string;
  name: string;
  slug?: string;
  status: string;
  city?: string | null;
  phone?: string | null;
  createdAt: string;
  _count?: { memberships: number; customers: number; orders: number };
};

export function PlatformDashboardPage() {
  const { t } = useTranslation();
  const user = useAuthStore((s) => s.user);
  const [data, setData] = useState<{
    totals: Record<string, number>;
    shops?: AdminShopRow[];
    recentShops: AdminShopRow[];
    recentEvents: Array<{ id: string; action: string; createdAt: string }>;
  } | null>(null);
  const [error, setError] = useState('');

  useEffect(() => {
    api
      .get('/platform-admin/dashboard')
      .then((r) => setData(r.data))
      .catch((err) => {
        const msg = getApiErrorMessage(err, t('common.error'));
        setError(msg);
        toastError(msg, t('platform.dashboard'));
      });
  }, [t]);

  if (error) {
    return (
      <div className="state-box">
        <p>{error}</p>
        <button className="btn" type="button" onClick={() => window.location.reload()}>
          {t('common.retry')}
        </button>
      </div>
    );
  }
  if (!data) return <div className="state-box">{t('common.loading')}</div>;

  const shops = data.shops?.length ? data.shops : data.recentShops;

  return (
    <div>
      <div className="page-header">
        <div>
          <h1>{t('platform.dashboard')}</h1>
          <p className="muted" style={{ margin: 0 }}>
            {user?.fullName || user?.email} · Platform admin
          </p>
        </div>
        <Link className="btn" to="/platform-admin/shops">
          {t('platform.shops')} ({data.totals.shops ?? shops.length})
        </Link>
      </div>

      <div className="stat-grid">
        <div className="stat">
          <div className="label">Total shops</div>
          <div className="value">{data.totals.shops ?? shops.length}</div>
        </div>
        <div className="stat">
          <div className="label">Active</div>
          <div className="value">{data.totals.activeShops ?? 0}</div>
        </div>
        <div className="stat">
          <div className="label">Suspended</div>
          <div className="value">{data.totals.suspendedShops ?? 0}</div>
        </div>
        <div className="stat">
          <div className="label">Pending</div>
          <div className="value">{data.totals.pendingShops ?? 0}</div>
        </div>
        <div className="stat">
          <div className="label">Users</div>
          <div className="value">{data.totals.users ?? 0}</div>
        </div>
      </div>

      <div className="panel">
        <div className="page-header" style={{ marginBottom: 12 }}>
          <h2 style={{ margin: 0 }}>All shops ({shops.length})</h2>
        </div>
        {!shops.length ? (
          <div className="state-box">{t('common.empty')}</div>
        ) : (
          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Name</th>
                  <th>City</th>
                  <th>Status</th>
                  <th>Staff</th>
                  <th>Customers</th>
                  <th>Orders</th>
                  <th>Created</th>
                </tr>
              </thead>
              <tbody>
                {shops.map((s) => (
                  <tr key={s.id}>
                    <td>
                      <Link to={`/platform-admin/shops/${s.id}`}>{s.name}</Link>
                      {s.slug ? <div className="muted" style={{ fontSize: 12 }}>{s.slug}</div> : null}
                    </td>
                    <td>{s.city || '—'}</td>
                    <td>
                      <span className="badge">{s.status}</span>
                    </td>
                    <td>{s._count?.memberships ?? '—'}</td>
                    <td>{s._count?.customers ?? '—'}</td>
                    <td>{s._count?.orders ?? '—'}</td>
                    <td>{new Date(s.createdAt).toLocaleString()}</td>
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

export function PlatformShopsPage() {
  const { t } = useTranslation();
  const [items, setItems] = useState<
    Array<{
      id: string;
      name: string;
      status: string;
      city?: string;
      _count?: { memberships: number; customers: number; orders: number };
    }>
  >([]);
  const [total, setTotal] = useState(0);
  const [search, setSearch] = useState('');
  const [status, setStatus] = useState('');
  const [error, setError] = useState('');

  async function load() {
    setError('');
    try {
      const { data } = await api.get('/platform-admin/shops', {
        params: {
          search: search || undefined,
          status: status || undefined,
          pageSize: 100,
        },
      });
      setItems(data.items || []);
      setTotal(data.total ?? data.items?.length ?? 0);
    } catch (err) {
      const msg = getApiErrorMessage(err, t('common.error'));
      setError(msg);
      toastError(msg, t('platform.shops'));
    }
  }

  useEffect(() => {
    void load();
  }, []);

  return (
    <div>
      <div className="page-header">
        <h1>
          {t('platform.shops')}{' '}
          <span className="muted" style={{ fontSize: '1rem', fontWeight: 500 }}>
            ({total})
          </span>
        </h1>
        <div className="toolbar">
          <input
            className="input"
            style={{ width: 200 }}
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder={t('common.search')}
          />
          <select
            className="select"
            style={{ width: 160 }}
            value={status}
            onChange={(e) => setStatus(e.target.value)}
          >
            <option value="">All</option>
            <option value="ACTIVE">ACTIVE</option>
            <option value="SUSPENDED">SUSPENDED</option>
            <option value="PENDING">PENDING</option>
          </select>
          <button className="btn" type="button" onClick={() => void load()}>
            {t('common.search')}
          </button>
        </div>
      </div>
      {error ? <div className="state-box">{error}</div> : null}
      <div className="panel table-wrap">
        <table>
          <thead>
            <tr>
              <th>Name</th>
              <th>City</th>
              <th>Status</th>
              <th>Staff</th>
              <th>Customers</th>
              <th>Orders</th>
            </tr>
          </thead>
          <tbody>
            {items.map((s) => (
              <tr key={s.id}>
                <td>
                  <Link to={`/platform-admin/shops/${s.id}`}>{s.name}</Link>
                </td>
                <td>{s.city || '—'}</td>
                <td>
                  <span className="badge">{s.status}</span>
                </td>
                <td>{s._count?.memberships ?? '—'}</td>
                <td>{s._count?.customers ?? '—'}</td>
                <td>{s._count?.orders ?? '—'}</td>
              </tr>
            ))}
          </tbody>
        </table>
        {!items.length && !error ? <div className="state-box">{t('common.empty')}</div> : null}
      </div>
    </div>
  );
}

function mediaUrl(path?: string | null) {
  if (!path) return '';
  if (path.startsWith('http')) return path;
  const apiBase = import.meta.env.VITE_API_URL || 'http://localhost:3000/api/v1';
  const origin = String(apiBase).replace(/\/api\/v1\/?$/, '');
  return `${origin}${path.startsWith('/') ? path : `/${path}`}`;
}

function toInputDate(value?: string | null) {
  if (!value) return '';
  return new Date(value).toISOString().slice(0, 10);
}

export function PlatformShopDetailPage() {
  const { id } = useParams();
  const { t } = useTranslation();
  const [shop, setShop] = useState<{
    id: string;
    name: string;
    status: string;
    subscriptionLifetimeFree?: boolean;
    trialEndsAt?: string | null;
    subscriptionExpiresAt?: string | null;
    statusHistory: Array<{ id: string; toStatus: string; reason?: string; createdAt: string }>;
    subscriptionProofs?: Array<{
      id: string;
      status: string;
      transactionId: string;
      amountInr: string | number;
      screenshotUrl: string;
      createdAt: string;
    }>;
    _count: { customers: number; orders: number };
  } | null>(null);
  const [reason, setReason] = useState('');
  const [lifetimeFree, setLifetimeFree] = useState(false);
  const [trialEndsAt, setTrialEndsAt] = useState('');
  const [subscriptionExpiresAt, setSubscriptionExpiresAt] = useState('');

  async function load() {
    const { data } = await api.get(`/platform-admin/shops/${id}`);
    setShop(data);
    setLifetimeFree(Boolean(data.subscriptionLifetimeFree));
    setTrialEndsAt(toInputDate(data.trialEndsAt));
    setSubscriptionExpiresAt(toInputDate(data.subscriptionExpiresAt));
  }

  useEffect(() => { void load(); }, [id]);

  async function setStatus(status: 'ACTIVE' | 'SUSPENDED') {
    await api.patch(`/platform-admin/shops/${id}/status`, { status, reason });
    setReason('');
    await load();
  }

  async function saveSubscription() {
    await api.patch(`/platform-admin/shops/${id}/subscription`, {
      subscriptionLifetimeFree: lifetimeFree,
      trialEndsAt: trialEndsAt || null,
      subscriptionExpiresAt: subscriptionExpiresAt || null,
    });
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
      <div className="panel" style={{ marginBottom: 16 }}>
        <h2>{t('platform.subscription')}</h2>
        <label style={{ display: 'flex', gap: 8, alignItems: 'center', marginBottom: 12 }}>
          <input type="checkbox" checked={lifetimeFree} onChange={(e) => setLifetimeFree(e.target.checked)} />
          {t('platform.lifetimeFree')}
        </label>
        <div className="field">
          <label>{t('platform.trialEndsAt')}</label>
          <input className="input" type="date" value={trialEndsAt} onChange={(e) => setTrialEndsAt(e.target.value)} />
        </div>
        <div className="field">
          <label>{t('platform.subscriptionExpiresAt')}</label>
          <input className="input" type="date" value={subscriptionExpiresAt} onChange={(e) => setSubscriptionExpiresAt(e.target.value)} />
        </div>
        <button className="btn" type="button" onClick={() => void saveSubscription()}>{t('platform.saveSettings')}</button>
        {!!shop.subscriptionProofs?.length && (
          <div className="table-wrap" style={{ marginTop: 16 }}>
            <table>
              <thead><tr><th>Txn</th><th>Amount</th><th>Status</th><th>Screenshot</th><th>When</th></tr></thead>
              <tbody>
                {shop.subscriptionProofs.map((p) => (
                  <tr key={p.id}>
                    <td>{p.transactionId}</td>
                    <td>₹{p.amountInr}</td>
                    <td><span className="badge">{p.status}</span></td>
                    <td>
                      <a href={mediaUrl(p.screenshotUrl)} target="_blank" rel="noreferrer">View</a>
                    </td>
                    <td>{new Date(p.createdAt).toLocaleString()}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
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
  const [cfg, setCfg] = useState({
    enabled: false,
    trialDays: 30,
    paidDays: 365,
    amountInr: 2999,
    upiId: '',
    qrImageUrl: '',
    instructions: '',
  });
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState('');

  async function load() {
    const { data } = await api.get('/platform-admin/subscription-config');
    setCfg({
      enabled: Boolean(data.enabled),
      trialDays: Number(data.trialDays ?? 30),
      paidDays: Number(data.paidDays ?? 365),
      amountInr: Number(data.amountInr ?? 2999),
      upiId: data.upiId || '',
      qrImageUrl: data.qrImageUrl || '',
      instructions: data.instructions || '',
    });
  }

  useEffect(() => { void load(); }, []);

  async function save(e: FormEvent) {
    e.preventDefault();
    setSaving(true);
    setMessage('');
    try {
      const { data } = await api.post('/platform-admin/subscription-config', cfg);
      setCfg(data);
      setMessage('Saved');
    } catch (err) {
      toastError(getApiErrorMessage(err, t('common.error')), t('platform.settings'));
    } finally {
      setSaving(false);
    }
  }

  async function onQrSelected(file: File | null) {
    if (!file) return;
    const form = new FormData();
    form.append('qr', file);
    try {
      const { data } = await api.post('/platform-admin/subscription-config/qr', form, {
        headers: { 'Content-Type': 'multipart/form-data' },
      });
      setCfg(data);
      setMessage('QR uploaded');
    } catch (err) {
      toastError(getApiErrorMessage(err, t('common.error')), t('platform.uploadQr'));
    }
  }

  return (
    <div>
      <div className="page-header"><h1>{t('platform.settings')}</h1></div>
      <form className="panel" onSubmit={(e) => void save(e)}>
        <h2>{t('platform.subscription')}</h2>
        <label style={{ display: 'flex', gap: 8, alignItems: 'center', marginBottom: 12 }}>
          <input
            type="checkbox"
            checked={cfg.enabled}
            onChange={(e) => setCfg((c) => ({ ...c, enabled: e.target.checked }))}
          />
          Enforce subscription (paywall)
        </label>
        <div className="field">
          <label>Trial days</label>
          <input className="input" type="number" value={cfg.trialDays}
            onChange={(e) => setCfg((c) => ({ ...c, trialDays: Number(e.target.value) }))} />
        </div>
        <div className="field">
          <label>Paid days (after approve)</label>
          <input className="input" type="number" value={cfg.paidDays}
            onChange={(e) => setCfg((c) => ({ ...c, paidDays: Number(e.target.value) }))} />
        </div>
        <div className="field">
          <label>Amount (INR)</label>
          <input className="input" type="number" value={cfg.amountInr}
            onChange={(e) => setCfg((c) => ({ ...c, amountInr: Number(e.target.value) }))} />
        </div>
        <div className="field">
          <label>UPI ID</label>
          <input className="input" value={cfg.upiId}
            onChange={(e) => setCfg((c) => ({ ...c, upiId: e.target.value }))} />
        </div>
        <div className="field">
          <label>Instructions</label>
          <textarea className="input" rows={3} value={cfg.instructions}
            onChange={(e) => setCfg((c) => ({ ...c, instructions: e.target.value }))} />
        </div>
        <div className="field">
          <label>{t('platform.uploadQr')}</label>
          <input type="file" accept="image/*" onChange={(e) => void onQrSelected(e.target.files?.[0] || null)} />
          {cfg.qrImageUrl ? (
            <div style={{ marginTop: 12 }}>
              <img src={mediaUrl(cfg.qrImageUrl)} alt="Subscription QR" style={{ maxWidth: 220, borderRadius: 12 }} />
            </div>
          ) : null}
        </div>
        <div className="toolbar">
          <button className="btn" type="submit" disabled={saving}>{t('platform.saveSettings')}</button>
          {message ? <span className="muted">{message}</span> : null}
        </div>
      </form>
    </div>
  );
}

export function PlatformSubscriptionProofsPage() {
  const { t } = useTranslation();
  const [status, setStatus] = useState('PENDING');
  const [items, setItems] = useState<Array<{
    id: string;
    status: string;
    transactionId: string;
    amountInr: string | number;
    screenshotUrl: string;
    note?: string | null;
    createdAt: string;
    shop?: { id: string; name: string };
    submittedBy?: { fullName: string; email?: string };
  }>>([]);
  const [note, setNote] = useState('');

  async function load() {
    const { data } = await api.get('/platform-admin/subscription-proofs', {
      params: { status: status || undefined },
    });
    setItems(data.items || []);
  }

  useEffect(() => { void load(); }, [status]);

  async function review(id: string, action: 'approve' | 'reject') {
    await api.post(`/platform-admin/subscription-proofs/${id}/${action}`, {
      reviewNote: note || undefined,
    });
    setNote('');
    await load();
  }

  return (
    <div>
      <div className="page-header">
        <h1>{t('platform.subscriptionProofs')}</h1>
        <select className="input" value={status} onChange={(e) => setStatus(e.target.value)} style={{ maxWidth: 180 }}>
          <option value="PENDING">PENDING</option>
          <option value="APPROVED">APPROVED</option>
          <option value="REJECTED">REJECTED</option>
          <option value="">ALL</option>
        </select>
      </div>
      <div className="panel" style={{ marginBottom: 12 }}>
        <div className="field">
          <label>Review note (optional)</label>
          <input className="input" value={note} onChange={(e) => setNote(e.target.value)} />
        </div>
      </div>
      <div className="panel table-wrap">
        <table>
          <thead>
            <tr>
              <th>Shop</th>
              <th>Submitted by</th>
              <th>Txn ID</th>
              <th>Amount</th>
              <th>Screenshot</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {items.map((p) => (
              <tr key={p.id}>
                <td>
                  {p.shop ? (
                    <Link to={`/platform-admin/shops/${p.shop.id}`}>{p.shop.name}</Link>
                  ) : '—'}
                </td>
                <td>{p.submittedBy?.fullName || '—'}</td>
                <td>{p.transactionId}</td>
                <td>₹{p.amountInr}</td>
                <td>
                  <a href={mediaUrl(p.screenshotUrl)} target="_blank" rel="noreferrer">View</a>
                </td>
                <td><span className="badge">{p.status}</span></td>
                <td>
                  {p.status === 'PENDING' ? (
                    <div className="toolbar">
                      <button className="btn" type="button" onClick={() => void review(p.id, 'approve')}>
                        {t('platform.approve')}
                      </button>
                      <button className="btn danger" type="button" onClick={() => void review(p.id, 'reject')}>
                        {t('platform.reject')}
                      </button>
                    </div>
                  ) : '—'}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {!items.length ? <div className="state-box">{t('common.empty')}</div> : null}
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
