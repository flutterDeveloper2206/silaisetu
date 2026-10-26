import { Navigate, Outlet, Route, Routes } from 'react-router-dom';
import { useEffect } from 'react';
import { useAuthStore } from '../core/auth/auth-store';
import { ShopLayout } from './layouts/ShopLayout';
import { PlatformLayout } from './layouts/PlatformLayout';
import { LoginPage } from '../features/auth/LoginPage';
import { RegisterPage } from '../features/auth/RegisterPage';
import { OnboardingPage } from '../features/onboarding/OnboardingPage';
import { DashboardPage } from '../features/dashboard/DashboardPage';
import { CustomersPage } from '../features/customers/CustomersPage';
import { OrdersPage } from '../features/orders/OrdersPage';
import { SettingsPage } from '../features/settings/SettingsPage';
import {
  CalendarPage,
  ReportsPage,
  StaffPage,
  TemplatesPage,
} from '../features/misc/SimplePages';
import {
  PlatformAuditPage,
  PlatformDashboardPage,
  PlatformHealthPage,
  PlatformLoginPage,
  PlatformSettingsPage,
  PlatformShopDetailPage,
  PlatformShopsPage,
  PlatformUsersPage,
} from '../features/platform-admin/PlatformPages';

function ShopGuard() {
  const user = useAuthStore((s) => s.user);
  const loading = useAuthStore((s) => s.loading);
  if (loading) return <div className="state-box">Loading…</div>;
  if (!user) return <Navigate to="/login" replace />;
  if (!user.memberships?.length) return <Navigate to="/onboarding" replace />;
  return <Outlet />;
}

function PlatformGuard() {
  const user = useAuthStore((s) => s.user);
  const loading = useAuthStore((s) => s.loading);
  if (loading) return <div className="state-box">Loading…</div>;
  if (!user?.isPlatformAdmin) return <Navigate to="/platform-admin/login" replace />;
  return <Outlet />;
}

export function AppRouter() {
  const hydrate = useAuthStore((s) => s.hydrate);
  useEffect(() => {
    void hydrate();
  }, [hydrate]);

  return (
    <Routes>
      <Route path="/" element={<Navigate to="/login" replace />} />
      <Route path="/login" element={<LoginPage />} />
      <Route path="/register" element={<RegisterPage />} />
      <Route path="/onboarding" element={<OnboardingPage />} />

      <Route path="/app" element={<ShopGuard />}>
        <Route element={<ShopLayout />}>
          <Route index element={<DashboardPage />} />
          <Route path="customers" element={<CustomersPage />} />
          <Route path="orders" element={<OrdersPage />} />
          <Route path="templates" element={<TemplatesPage />} />
          <Route path="calendar" element={<CalendarPage />} />
          <Route path="reports" element={<ReportsPage />} />
          <Route path="staff" element={<StaffPage />} />
          <Route path="settings" element={<SettingsPage />} />
        </Route>
      </Route>

      <Route path="/platform-admin/login" element={<PlatformLoginPage />} />
      <Route path="/platform-admin" element={<PlatformGuard />}>
        <Route element={<PlatformLayout />}>
          <Route index element={<PlatformDashboardPage />} />
          <Route path="shops" element={<PlatformShopsPage />} />
          <Route path="shops/:id" element={<PlatformShopDetailPage />} />
          <Route path="users" element={<PlatformUsersPage />} />
          <Route path="audit-logs" element={<PlatformAuditPage />} />
          <Route path="settings" element={<PlatformSettingsPage />} />
          <Route path="system-health" element={<PlatformHealthPage />} />
        </Route>
      </Route>

      <Route path="*" element={<Navigate to="/login" replace />} />
    </Routes>
  );
}
