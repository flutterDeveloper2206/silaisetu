import { NavLink, Outlet } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { brand } from '../../core/config/brand';
import { useAuthStore } from '../../core/auth/auth-store';

const links = [
  ['', 'nav.dashboard'],
  ['customers', 'nav.customers'],
  ['orders', 'nav.orders'],
  ['templates', 'nav.templates'],
  ['calendar', 'nav.calendar'],
  ['reports', 'nav.reports'],
  ['staff', 'nav.staff'],
  ['settings', 'nav.settings'],
] as const;

export function ShopLayout() {
  const { t } = useTranslation();
  const logout = useAuthStore((s) => s.logout);
  const user = useAuthStore((s) => s.user);

  return (
    <div className="app-shell">
      <aside className="sidebar">
        <div className="brand-block">
          <div className="name">{brand.name}</div>
          <div className="tag">{t('brand.tagline')}</div>
        </div>
        <nav>
          {links.map(([path, key]) => (
            <NavLink
              key={path}
              to={path ? `/app/${path}` : '/app'}
              end={!path}
              className={({ isActive }) => (isActive ? 'active' : undefined)}
            >
              {t(key)}
            </NavLink>
          ))}
        </nav>
        <div style={{ marginTop: 'auto', padding: '0.75rem' }}>
          <div className="muted" style={{ fontSize: '0.85rem', marginBottom: 8 }}>
            {user?.fullName}
          </div>
          <button type="button" className="btn secondary" style={{ width: '100%' }} onClick={() => void logout()}>
            {t('nav.logout')}
          </button>
        </div>
      </aside>
      <main className="main">
        <Outlet />
      </main>
    </div>
  );
}
