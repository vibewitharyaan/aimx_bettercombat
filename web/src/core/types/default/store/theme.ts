export const THEMES = ['blue', 'red', 'green', 'purple', 'orange', 'pink', 'custom'] as const;

export type ThemeName = typeof THEMES[number];

export interface ThemeManager {
  readonly setTheme: (theme: ThemeName) => void;
  readonly isValidTheme: (theme: string) => theme is ThemeName;
  readonly getValidThemes: () => readonly ThemeName[];
}

export interface ThemeStore {
  readonly themeName: ThemeName;
  readonly setTheme: (name: string) => void;
  readonly getValidThemes: () => readonly ThemeName[];
  readonly isValidTheme: (theme: string) => theme is ThemeName;
}

export interface ThemeConfig {
  readonly defaultTheme: ThemeName;
  readonly storageKey: string;
}
