import { useState, type FormEvent } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useAuthStore } from '../../core/auth/auth-store';

export function RegisterPage() {
  const { t } = useTranslation();
  const register = useAuthStore((s) => s.register);
  const navigate = useNavigate();
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      await register({ email, password, fullName });
      navigate('/onboarding');
    } catch {
      setError(t('common.error'));
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="auth-page">
      <form className="auth-card" onSubmit={onSubmit}>
        <h1>{t('auth.register')}</h1>
        <div className="field">
          <label>{t('auth.fullName')}</label>
          <input className="input" value={fullName} onChange={(e) => setFullName(e.target.value)} required />
        </div>
        <div className="field">
          <label>{t('auth.email')}</label>
          <input className="input" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required />
        </div>
        <div className="field">
          <label>{t('auth.password')}</label>
          <input className="input" type="password" minLength={8} value={password} onChange={(e) => setPassword(e.target.value)} required />
        </div>
        {error && <p className="error-text">{error}</p>}
        <button className="btn" disabled={loading} style={{ width: '100%' }}>
          {loading ? t('common.loading') : t('auth.register')}
        </button>
        <p className="muted" style={{ marginTop: 16 }}>
          {t('auth.hasAccount')} <Link to="/login">{t('auth.login')}</Link>
        </p>
      </form>
    </div>
  );
}
