export type PreloaderFunction = (src: string) => Promise<void>;

export interface AssetGroup {
  readonly assets: readonly string[];
  readonly preloader: PreloaderFunction;
}

export interface AssetCollection {
  readonly images: Record<string, string>;
  readonly audio: Record<string, string>;
  readonly icons: Record<string, string>;
}
