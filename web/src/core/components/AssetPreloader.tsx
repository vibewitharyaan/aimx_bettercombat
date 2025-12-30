import { useEffect } from 'react';
import { preloadAssets } from '../utils/assets';

const PRELOAD_DELAY_MS = 500;

export function AssetPreloader () {
  useEffect(() => {
    const preloadAfterPaint = () => {
      preloadAssets().catch((error) => {
        console.error('Asset preloading failed:', error);
      });
    };

    // try requestIdleCallback if available, otherwise setTimeout
    if ('requestIdleCallback' in window) {
      requestIdleCallback(preloadAfterPaint, { timeout: PRELOAD_DELAY_MS });
    } else {
      setTimeout(preloadAfterPaint, PRELOAD_DELAY_MS);
    }
  }, []);

  return null;
}

