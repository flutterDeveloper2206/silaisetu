import { useState, type FormEvent } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { brand } from '../../core/config/brand';
import { useAuthStore } from '../../core/auth/auth-store';

export function LoginPage() {
  const { t } = useTranslation();
  const login = useAuthStore((s) => s.login);
  const navigate = useNavigate();
  const [email, setEmail] = useState('owner1@silaisetu.local');
  const [password, setPassword] = useState('OwnerDemo_123!');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      const user = await login(email, password);
      if (!user.memberships?.length) navigate('/onboarding');
      else navigate('/app');
    } catch {
      setError(t('common.error'));
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="auth-page">
      <form className="auth-card" onSubmit={onSubmit}>
        <div className="muted">{brand.name}</div>
        <h1>{t('auth.login')}</h1>
        <p className="muted">{t('brand.tagline')}</p>
        <div className="field">
          <label htmlFor="email">{t('auth.email')}</label>
          <input id="email" className="input" value={email} onChange={(e) => setEmail(e.target.value)} required />
        </div>
        <div className="field">
          <label htmlFor="password">{t('auth.password')}</label>
          <input id="password" type="password" className="input" value={password} onChange={(e) => setPassword(e.target.value)} required />
        </div>
        {error && <p className="error-text">{error}</p>}
        <button className="btn" type="submit" disabled={loading} style={{ width: '100%' }}>
          {loading ? t('common.loading') : t('auth.login')}
        </button>
        <p className="muted" style={{ marginTop: 16 }}>
          {t('auth.noAccount')} <Link to="/register">{t('auth.register')}</Link>
        </p>
        <p className="muted">
          <Link to="/platform-admin/login">{t('auth.platformLogin')}</Link>
        </p>
      </form>
    </div>
  );
}
