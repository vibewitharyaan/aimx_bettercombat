import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { THEMES, type ThemeName, type ThemeStore, type ThemeConfig } from '../../core/types/default/store/theme';

const CONFIG: ThemeConfig = {
  defaultTheme: 'custom',
  storageKey: 'theme-storage',
} as const;

class ThemeManager {
  setTheme (theme: ThemeName): void {
    if (typeof document === 'undefined') return;
    document.documentElement.setAttribute('data-theme', theme);
  }

  isValidTheme (theme: string): theme is ThemeName {
    return THEMES.includes(theme as ThemeName);
  }

  getValidThemes (): readonly ThemeName[] {
    return THEMES;
  }
}

const manager = new ThemeManager();

export const useThemeStore = create<ThemeStore>()(
  persist(
    (set, get) => ({
      themeName: CONFIG.defaultTheme,

      setTheme: (name: string) => {
        const isValid = manager.isValidTheme(name);
        const theme = isValid ? (name as ThemeName) : CONFIG.defaultTheme;

        if (!isValid) {
          console.warn(`Invalid theme: ${name}. Using default: ${CONFIG.defaultTheme}`);
        }

        if (get().themeName !== theme) {
          manager.setTheme(theme);
          set({ themeName: theme });
        }
      },

      getValidThemes: () => manager.getValidThemes(),
      isValidTheme: (theme: string): theme is ThemeName => manager.isValidTheme(theme),
    }),
    {
      name: CONFIG.storageKey,
      partialize: (state) => ({ themeName: state.themeName }),
      onRehydrateStorage: () => (state) => {
        if (state?.themeName) {
          manager.setTheme(state.themeName);
        } else {
          manager.setTheme(CONFIG.defaultTheme);
        }
      },
    }
  )
);

if (typeof document !== 'undefined') {
  manager.setTheme(CONFIG.defaultTheme);
}

export { THEMES } from '../../core/types/default/store/theme';
export type { ThemeName } from '../../core/types/default/store/theme';
