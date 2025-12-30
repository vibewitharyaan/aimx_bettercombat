import DOMPurify from 'dompurify';
import { useCallback } from 'react';
import { create } from 'zustand';
import { subscribeWithSelector } from 'zustand/middleware';
import type { RawLocale, Replacements, LocaleStore, TranslationFunction, LocaleCache } from '../../core/types/default/store/locale';

class LocaleCacheManager implements LocaleCache {
  private cache = new Map<string, string>();

  get (key: string): string | undefined {
    return this.cache.get(key);
  }

  set (key: string, value: string): void {
    this.cache.set(key, value);
  }

  clear (): void {
    this.cache.clear();
  }

  has (key: string): boolean {
    return this.cache.has(key);
  }
}

const cacheManager = new LocaleCacheManager();

export const useLocaleStore = create<LocaleStore>()(
  subscribeWithSelector((set) => ({
    locale: {},
    setLocale: (locale) => {
      cacheManager.clear();
      set({ locale });
    },
    clear: () => cacheManager.clear(),
  }))
);

const lookupTranslation = (data: RawLocale, path: string): string | undefined => {
  const parts = path.split('.');
  let node: unknown = data;

  for (const part of parts) {
    if (typeof node !== 'object' || node === null || !(part in node)) {
      return undefined;
    }
    node = (node as Record<string, unknown>)[part];
  }

  return typeof node === 'string' ? node : undefined;
};

const createCacheKey = (key: string, replacements: Replacements): string => {
  if (Object.keys(replacements).length === 0) return key;

  const sortedKeys = Object.keys(replacements).sort();
  const replStr = sortedKeys.map(k => `${k}:${String(replacements[k])}`).join('|');
  return `${key}-${replStr}`;
};

const applyReplacements = (phrase: string, replacements: Replacements): string => {
  if (Object.keys(replacements).length === 0) return phrase;

  return phrase.replace(/\{(\w+)\}/g, (_, key) =>
    key in replacements ? String(replacements[key]) : `{${key}}`
  );
};

export const t: TranslationFunction = (
  key: string,
  arg2?: Replacements | string,
  arg3?: string
): string => {
  const replacements: Replacements = typeof arg2 === 'object' && arg2 !== null ? arg2 : {};
  const fallback: string | undefined = typeof arg2 === 'string' ? arg2 : arg3;

  const cacheKey = createCacheKey(key, replacements);
  if (cacheManager.has(cacheKey)) {
    return cacheManager.get(cacheKey)!;
  }

  const locale = useLocaleStore.getState().locale;
  const rawPhrase = lookupTranslation(locale, key) ?? fallback ?? key;
  const processedPhrase = applyReplacements(rawPhrase, replacements);
  const sanitizedPhrase = DOMPurify.sanitize(processedPhrase, {
    ALLOWED_TAGS: ['br', 'ul', 'ol', 'li', 'b', 'strong', 'em', 'i', 'p'],
    ALLOWED_ATTR: []
  });

  cacheManager.set(cacheKey, sanitizedPhrase);
  return sanitizedPhrase;
};

export const useT = (): TranslationFunction => {
  const locale = useLocaleStore((state) => state.locale);

  return useCallback(
    (key: string, arg2?: Replacements | string, arg3?: string): string => {
      if (arg2 === undefined) {
        return t(key);
      }
      if (typeof arg2 === 'string') {
        return t(key, arg2);
      }
      if (arg3 === undefined) {
        return t(key, arg2);
      }
      return t(key, arg2, arg3);
    },
    [locale]
  );
};

export type { RawLocale, Replacements } from '../../core/types/default/store/locale';

/**
 * Usage Examples:
 *
 * import { useT, t } from './locale';
 *
 * // 1) Simple key only
 * const title = t('welcome.title');
 *
 * // 2) Key with fallback
 * const buttonText = t('actions.save', 'Save Changes');
 *
 * // 3) Key with single replacement
 * const message = t('welcome.message', { playerName: 'Alex' });
 *
 * // 4) Key with multiple replacements
 * const greeting = t('user.greeting', { firstName: 'John', lastName: 'Doe' });
 *
 * // 5) Key with replacements and fallback
 * const notification = t('user.joined', { name: 'Alice' }, '{name} has joined the server');
 *
 * // 6) React Hook usage in components:
 * function MyComponent() {
 *   const translate = useT();
 *
 *   return (
 *     <div>
 *       <h1>{translate('page.title')}</h1>
 *       <p>{translate('user.welcome', { name: 'Alex' })}</p>
 *       <button>{translate('actions.continue', 'Continue')}</button>
 *     </div>
 *   );
 * }
 *
 * // 7) Dynamic key selection
 * const statusMessage = t(isOnline ? 'status.online' : 'status.offline', { server: 'Main' });
 */
