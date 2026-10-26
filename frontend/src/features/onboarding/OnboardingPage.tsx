import { useState, type FormEvent } from 'react';
import { useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { api, setShopId } from '../../core/api/client';
import { useAuthStore } from '../../core/auth/auth-store';

export function OnboardingPage() {
  const { t, i18n } = useTranslation();
  const navigate = useNavigate();
  const hydrate = useAuthStore((s) => s.hydrate);
  const [name, setName] = useState('');
  const [phone, setPhone] = useState('');
  const [city, setCity] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      const { data } = await api.post('/shops', {
        name,
        phone,
        city,
        defaultLanguage: i18n.language || 'gu',
        measurementUnit: 'INCH',
      });
      setShopId(data.id);
      await hydrate();
      navigate('/app');
    } catch {
      setError(t('common.error'));
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="auth-page">
      <form className="auth-card" onSubmit={onSubmit}>
        <h1>{t('onboarding.title')}</h1>
        <div className="field">
          <label>{t('onboarding.shopName')}</label>
          <input className="input" value={name} onChange={(e) => setName(e.target.value)} required minLength={2} />
        </div>
        <div className="field">
          <label>{t('customers.phone')}</label>
          <input className="input" value={phone} onChange={(e) => setPhone(e.target.value)} />
        </div>
        <div className="field">
          <label>City</label>
          <input className="input" value={city} onChange={(e) => setCity(e.target.value)} />
        </div>
        {error && <p className="error-text">{error}</p>}
        <button className="btn" disabled={loading} style={{ width: '100%' }}>
          {loading ? t('common.loading') : t('onboarding.continue')}
        </button>
      </form>
    </div>
  );
}
