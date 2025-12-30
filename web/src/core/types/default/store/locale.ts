export interface RawLocale {
  readonly [key: string]: string | RawLocale;
}

export type Replacements = Record<string, string | number | boolean>;

export interface LocaleStore {
  readonly locale: RawLocale;
  readonly setLocale: (locale: RawLocale) => void;
  readonly clear: () => void;
}

export interface TranslationFunction {
  (key: string): string;
  (key: string, fallback: string): string;
  (key: string, replacements: Replacements): string;
  (key: string, replacements: Replacements, fallback: string): string;
}

export interface LocaleCache {
  readonly get: (key: string) => string | undefined;
  readonly set: (key: string, value: string) => void;
  readonly clear: () => void;
  readonly has: (key: string) => boolean;
}

export interface LocaleConfig {
  readonly cacheEnabled: boolean;
  readonly sanitizeOutput: boolean;
}
