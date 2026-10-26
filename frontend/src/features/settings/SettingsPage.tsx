import { useTranslation } from 'react-i18next';
import { useTheme, type ThemeMode } from '../../core/theme/theme';

export function SettingsPage() {
  const { t, i18n } = useTranslation();
  const { mode, setMode } = useTheme();

  return (
    <div>
      <div className="page-header">
        <h1>{t('nav.settings')}</h1>
      </div>
      <div className="panel" style={{ maxWidth: 480 }}>
        <div className="field">
          <label>{t('common.language')}</label>
          <select
            className="select"
            value={i18n.language}
            onChange={(e) => {
              void i18n.changeLanguage(e.target.value);
              localStorage.setItem('ss_lang', e.target.value);
            }}
          >
            <option value="gu">ગુજરાતી</option>
            <option value="hi">हिन्दी</option>
            <option value="en">English</option>
          </select>
        </div>
        <div className="field">
          <label>{t('common.theme')}</label>
          <select
            className="select"
            value={mode}
            onChange={(e) => setMode(e.target.value as ThemeMode)}
          >
            <option value="system">{t('common.system')}</option>
            <option value="light">{t('common.light')}</option>
            <option value="dark">{t('common.dark')}</option>
          </select>
        </div>
      </div>
    </div>
  );
}
