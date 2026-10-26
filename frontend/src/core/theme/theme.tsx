import {
  createContext,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react';

export type ThemeMode = 'light' | 'dark' | 'system';

const ThemeCtx = createContext<{
  mode: ThemeMode;
  resolved: 'light' | 'dark';
  setMode: (m: ThemeMode) => void;
} | null>(null);

function resolve(mode: ThemeMode): 'light' | 'dark' {
  if (mode === 'system') {
    return window.matchMedia('(prefers-color-scheme: dark)').matches
      ? 'dark'
      : 'light';
  }
  return mode;
}

export function ThemeProvider({ children }: { children: ReactNode }) {
  const [mode, setModeState] = useState<ThemeMode>(
    () => (localStorage.getItem('ss_theme') as ThemeMode) || 'system',
  );
  const [resolved, setResolved] = useState<'light' | 'dark'>(() =>
    resolve(mode),
  );

  useEffect(() => {
    const apply = () => {
      const r = resolve(mode);
      setResolved(r);
      document.documentElement.dataset.theme = r;
    };
    apply();
    const mq = window.matchMedia('(prefers-color-scheme: dark)');
    const onChange = () => mode === 'system' && apply();
    mq.addEventListener('change', onChange);
    return () => mq.removeEventListener('change', onChange);
  }, [mode]);

  const setMode = (m: ThemeMode) => {
    localStorage.setItem('ss_theme', m);
    setModeState(m);
  };

  const value = useMemo(() => ({ mode, resolved, setMode }), [mode, resolved]);
  return <ThemeCtx.Provider value={value}>{children}</ThemeCtx.Provider>;
}

export function useTheme() {
  const ctx = useContext(ThemeCtx);
  if (!ctx) throw new Error('ThemeProvider missing');
  return ctx;
}
