import { isEnvBrowser } from './misc';

interface DebugEvent<T = unknown> {
  action: string;
  data: T;
}

const IS_DEV_BROWSER = isEnvBrowser();

export const debugData = <P> (events: DebugEvent<P>[]): void => {
  if (!IS_DEV_BROWSER) return;
  for (const event of events) {
    window.dispatchEvent(
      new MessageEvent('message', {
        data: {
          action: event.action,
          data: event.data,
        },
      })
    );
  }
};
