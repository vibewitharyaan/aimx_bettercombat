import { lazy, Suspense, useEffect } from 'react';
import { fetchNui } from './core/utils/bridge';
import { isEnvBrowser } from './core/utils/misc';
import { useVirtualCanvasScale } from './core/hooks/useVirtualCanvasScale';
import { useServerSync } from './shared/hooks/useServerSync';
import { AssetPreloader } from './core/components/AssetPreloader';

const Example = lazy(() => import('./features/example').then(m => ({ default: m.ExampleComponent })));
const DevContainer = import.meta.env.DEV ? lazy(() => import('./features/dev')) : null;

export function App (): JSX.Element {
  useServerSync();
  useVirtualCanvasScale();

  useEffect(() => {
    fetchNui('uiLoaded', true);
  }, []);

  return (
    <div className="app-wrapper bg-transparent">
      {isEnvBrowser() && DevContainer && (
        <Suspense fallback={null}>
          <DevContainer />
        </Suspense>
      )}
      <Suspense fallback={null}>
        <Example />
      </Suspense>
      <AssetPreloader />
    </div>
  );
}
