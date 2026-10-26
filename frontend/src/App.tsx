import { BrowserRouter } from 'react-router-dom';
import { ThemeProvider } from './core/theme/theme';
import { AppRouter } from './app/router';
import './core/i18n';

export default function App() {
  return (
    <ThemeProvider>
      <BrowserRouter>
        <AppRouter />
      </BrowserRouter>
    </ThemeProvider>
  );
}
