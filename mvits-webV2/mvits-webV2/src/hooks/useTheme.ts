import { useCallback, useEffect, useState } from 'react';

export type ThemeMode = 'light' | 'dark' | 'system';

const STORAGE_KEY = 'theme';
const darkMediaQuery = typeof window !== 'undefined' ? window.matchMedia('(prefers-color-scheme: dark)') : null;

function applyTheme(dark: boolean) {
  document.documentElement.classList.toggle('dark', dark);
}

export function useTheme() {
  const [mode, setMode] = useState<ThemeMode>(() => {
    const saved = localStorage.getItem(STORAGE_KEY);
    return saved === 'dark' || saved === 'light' || saved === 'system' ? saved : 'system';
  });
  const [systemDark, setSystemDark] = useState(() => !!darkMediaQuery?.matches);

  useEffect(() => {
    if (!darkMediaQuery) return;
    const onChange = (event: MediaQueryListEvent) => setSystemDark(event.matches);
    darkMediaQuery.addEventListener('change', onChange);
    return () => darkMediaQuery.removeEventListener('change', onChange);
  }, []);

  useEffect(() => {
    applyTheme(mode === 'dark' || (mode === 'system' && systemDark));
  }, [mode, systemDark]);

  const setTheme = useCallback((next: ThemeMode) => {
    setMode(next);
    localStorage.setItem(STORAGE_KEY, next);
  }, []);

  const isDarkMode = mode === 'dark' || (mode === 'system' && systemDark);

  const toggleTheme = useCallback(() => {
    setTheme(isDarkMode ? 'light' : 'dark');
  }, [isDarkMode, setTheme]);

  return { mode, isDarkMode, setTheme, toggleTheme };
}
