export interface PlayOptions {
  readonly loop?: boolean;
  readonly fade?: boolean;
  readonly fadeDuration?: number;
  readonly volume?: number;
  readonly fadeCurve?: "linear" | "exponential";
  readonly onEnd?: () => void;
  readonly onError?: (error: Error) => void;
}

export type AudioInstanceId = string;

export type FadeCurve = "linear" | "exponential";

export interface UIAudioHook {
  readonly play: (src: string, options?: PlayOptions) => AudioInstanceId;
  readonly stop: (
    id: AudioInstanceId,
    fade?: boolean,
    fadeDuration?: number,
    fadeCurve?: FadeCurve,
    onComplete?: () => void
  ) => void;
  readonly stopAll: (
    fade?: boolean,
    fadeDuration?: number,
    fadeCurve?: FadeCurve
  ) => void;
  readonly cleanupAll: () => void;
  readonly updateVolume: (id: AudioInstanceId, volume: number) => void;
}
