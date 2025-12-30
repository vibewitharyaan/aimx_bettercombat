export const isEnvBrowser = (): boolean => !('invokeNative' in window);
export const noop = () => { };

export const debugMsg = (...args: unknown[]): void => {
  if (isEnvBrowser()) console.log(...args);
};
