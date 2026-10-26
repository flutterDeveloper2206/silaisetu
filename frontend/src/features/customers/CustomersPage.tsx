import { useEffect, useState, type FormEvent } from 'react';
import { useTranslation } from 'react-i18next';
import { api } from '../../core/api/client';

type Customer = {
  id: string;
  fullName: string;
  phone: string;
  city?: string;
  notes?: string;
};

export function CustomersPage() {
  const { t } = useTranslation();
  const [items, setItems] = useState<Customer[]>([]);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [fullName, setFullName] = useState('');
  const [phone, setPhone] = useState('');
  const [showForm, setShowForm] = useState(false);

  async function load(q = search) {
    setLoading(true);
    setError('');
    try {
      const { data } = await api.get('/customers', { params: { search: q || undefined } });
      setItems(data.items || []);
    } catch {
      setError(t('common.error'));
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    void load();
  }, []);

  async function create(e: FormEvent) {
    e.preventDefault();
    await api.post('/customers', { fullName, phone });
    setFullName('');
    setPhone('');
    setShowForm(false);
    await load();
  }

  return (
    <div>
      <div className="page-header">
        <h1>{t('customers.title')}</h1>
        <div className="toolbar">
          <input
            className="input"
            style={{ width: 220 }}
            placeholder={t('common.search')}
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            onKeyDown={(e) => e.key === 'Enter' && void load()}
          />
          <button type="button" className="btn secondary" onClick={() => void load()}>{t('common.search')}</button>
          <button type="button" className="btn" onClick={() => setShowForm((v) => !v)}>{t('customers.add')}</button>
        </div>
      </div>

      {showForm && (
        <form className="panel" style={{ marginBottom: 16 }} onSubmit={create}>
          <div className="row">
            <div className="field grow">
              <label>{t('customers.name')}</label>
              <input className="input" value={fullName} onChange={(e) => setFullName(e.target.value)} required />
            </div>
            <div className="field grow">
              <label>{t('customers.phone')}</label>
              <input className="input" value={phone} onChange={(e) => setPhone(e.target.value)} required minLength={8} />
            </div>
          </div>
          <button className="btn" type="submit">{t('common.save')}</button>
        </form>
      )}

      {loading && <div className="state-box">{t('common.loading')}</div>}
      {error && <div className="state-box"><p>{error}</p><button className="btn" onClick={() => void load()}>{t('common.retry')}</button></div>}
      {!loading && !error && !items.length && <div className="state-box">{t('common.empty')}</div>}
      {!loading && !!items.length && (
        <div className="panel table-wrap">
          <table>
            <thead>
              <tr>
                <th>{t('customers.name')}</th>
                <th>{t('customers.phone')}</th>
              </tr>
            </thead>
            <tbody>
              {items.map((c) => (
                <tr key={c.id}>
                  <td>{c.fullName}</td>
                  <td>{c.phone}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
