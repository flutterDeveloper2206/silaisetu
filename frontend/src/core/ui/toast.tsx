import { useEffect } from 'react';
import { create } from 'zustand';

type ToastTone = 'error' | 'success' | 'info';

type ToastItem = {
  id: number;
  message: string;
  title?: string;
  tone: ToastTone;
};

type ToastState = {
  items: ToastItem[];
  show: (message: string, opts?: { title?: string; tone?: ToastTone }) => void;
  error: (message: string, title?: string) => void;
  success: (message: string, title?: string) => void;
  dismiss: (id: number) => void;
};

let seq = 0;

export const useToastStore = create<ToastState>((set, get) => ({
  items: [],
  show: (message, opts) => {
    const id = ++seq;
    const tone = opts?.tone ?? 'info';
    set({ items: [...get().items, { id, message, title: opts?.title, tone }] });
    window.setTimeout(() => get().dismiss(id), tone === 'error' ? 5000 : 3500);
  },
  error: (message, title) => get().show(message, { title, tone: 'error' }),
  success: (message, title) => get().show(message, { title, tone: 'success' }),
  dismiss: (id) => set({ items: get().items.filter((t) => t.id !== id) }),
}));

export function toastError(message: string, title?: string) {
  useToastStore.getState().error(message, title);
}

export function toastSuccess(message: string, title?: string) {
  useToastStore.getState().success(message, title);
}

export function ToastHost() {
  const items = useToastStore((s) => s.items);
  const dismiss = useToastStore((s) => s.dismiss);

  useEffect(() => {
    // ensure host is mounted for portal-less fixed toasts
  }, []);

  if (!items.length) return null;

  return (
    <div className="toast-stack" aria-live="polite">
      {items.map((t) => (
        <div
          key={t.id}
          className={`toast toast-${t.tone}`}
          role={t.tone === 'error' ? 'alert' : 'status'}
          onClick={() => dismiss(t.id)}
        >
          {t.title ? <div className="toast-title">{t.title}</div> : null}
          <div className="toast-body">{t.message}</div>
        </div>
      ))}
    </div>
  );
}
