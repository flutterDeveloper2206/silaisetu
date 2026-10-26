import { BrowserRouter } from 'react-router-dom';
import { ThemeProvider } from './core/theme/theme';
import { AppRouter } from './app/router';
import { ToastHost } from './core/ui/toast';
import './core/i18n';

export default function App() {
  return (
    <ThemeProvider>
      <BrowserRouter>
        <AppRouter />
        <ToastHost />
      </BrowserRouter>
    </ThemeProvider>
  );
}
