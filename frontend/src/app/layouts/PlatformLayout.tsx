import { NavLink, Outlet } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { brand } from '../../core/config/brand';
import { useAuthStore } from '../../core/auth/auth-store';

const links = [
  ['', 'platform.dashboard'],
  ['shops', 'platform.shops'],
  ['subscription-proofs', 'platform.subscriptionProofs'],
  ['users', 'platform.users'],
  ['audit-logs', 'platform.audit'],
  ['settings', 'platform.settings'],
  ['system-health', 'platform.health'],
] as const;

export function PlatformLayout() {
  const { t } = useTranslation();
  const logout = useAuthStore((s) => s.logout);

  return (
    <div className="app-shell">
      <aside className="sidebar">
        <div className="brand-block">
          <div className="name">{brand.name}</div>
          <div className="tag">Platform Admin</div>
        </div>
        <nav>
          {links.map(([path, key]) => (
            <NavLink
              key={path}
              to={path ? `/platform-admin/${path}` : '/platform-admin'}
              end={!path}
              className={({ isActive }) => (isActive ? 'active' : undefined)}
            >
              {t(key)}
            </NavLink>
          ))}
        </nav>
        <button
          type="button"
          className="btn secondary"
          style={{ marginTop: 'auto' }}
          onClick={() => void logout()}
        >
          {t('nav.logout')}
        </button>
      </aside>
      <main className="main">
        <Outlet />
      </main>
    </div>
  );
}
