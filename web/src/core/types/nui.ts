// FiveM-specific window extensions injected by CEF runtime
interface Window {
  GetParentResourceName?: () => string;
  invokeNative?: (nativeName: string, ...args: unknown[]) => unknown;
}

