import { useLocaleStore } from '../store/locale';
import type { RawLocale } from '../store/locale';
import type { LocaleStore } from '../../core/types/default/store/locale';
import { useThemeStore } from '../store/theme';
import type { ThemeStore } from '../../core/types/default/store/theme';
import { useNuiEvent } from '../../core/utils/bridge';

interface InitEventData {
  locale?: RawLocale;
  theme?: string;
}

export function useServerSync (): void {
  const setLocale = useLocaleStore((state: LocaleStore) => state.setLocale);
  const setTheme = useThemeStore((state: ThemeStore) => state.setTheme);

  useNuiEvent<InitEventData>('init', (data) => {
    if (data?.locale) setLocale(data.locale);
    if (data?.theme) setTheme(data.theme);
  });
}
