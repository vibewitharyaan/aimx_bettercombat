import { useCallback, useEffect, useRef } from "react";
import type { PlayOptions, AudioInstanceId, FadeCurve, UIAudioHook } from "../types/default/hooks/sound-effect";

const defaultFadeDuration = 300;
const defaultVolume = 100;

function useUIAudio (): UIAudioHook {
  const instances = useRef(new Map<AudioInstanceId, HTMLAudioElement>());
  const fadeTimeouts = useRef(new Map<AudioInstanceId, ReturnType<typeof setTimeout>>());

  const generateId = (): AudioInstanceId => Math.random().toString(36).substring(2, 10);

  const clearFadeTimeout = (id: AudioInstanceId) => {
    const timeout = fadeTimeouts.current.get(id);
    if (timeout) {
      clearTimeout(timeout);
      fadeTimeouts.current.delete(id);
    }
  };

  const fadeVolume = (
    id: AudioInstanceId,
    audio: HTMLAudioElement,
    from: number,
    to: number,
    duration: number,
    curve: FadeCurve,
    onComplete?: () => void
  ) => {
    const fromDecimal = Math.min(Math.max(from / 100, 0), 1);
    const toDecimal = Math.min(Math.max(to / 100, 0), 1);

    if (from < 1 || from > 100 || to < 1 || to > 100) {
      console.warn('Volume should be between 1 and 100');
    }

    const startTime = performance.now();

    const step = () => {
      if (!instances.current.has(id)) return;

      const elapsed = performance.now() - startTime;
      const progress = Math.min(elapsed / duration, 1);

      let newVolume: number;
      if (curve === "linear") {
        newVolume = fromDecimal + (toDecimal - fromDecimal) * progress;
      } else {
        newVolume = fromDecimal * Math.pow(toDecimal / fromDecimal, progress);
      }

      audio.volume = Math.min(Math.max(newVolume, 0), 1);

      if (progress < 1) {
        const timeout = setTimeout(step, 16);
        fadeTimeouts.current.set(id, timeout);
      } else {
        fadeTimeouts.current.delete(id);
        onComplete?.();
      }
    };

    step();
  };

  const play = useCallback(
    (src: string, options: PlayOptions = {}): AudioInstanceId => {
      const {
        loop = false,
        fade = false,
        fadeDuration = defaultFadeDuration,
        volume = defaultVolume,
        fadeCurve = "linear",
        onEnd,
        onError,
      } = options;

      if (volume < 1 || volume > 100) {
        console.warn('Volume should be between 1 and 100, clamping value');
      }

      const volumeDecimal = Math.min(Math.max(volume / 100, 0), 1);

      const id = generateId();
      const audio = new Audio(src);
      audio.preload = "auto";
      audio.crossOrigin = "anonymous";
      audio.loop = loop;
      audio.volume = fade ? 0 : volumeDecimal;

      const cleanup = () => {
        audio.pause();
        audio.remove();
        instances.current.delete(id);
        clearFadeTimeout(id);
        onEnd?.();
      };

      audio.onended = () => {
        if (!audio.loop) cleanup();
      };

      audio.onerror = () => {
        onError?.(new Error(`Failed to play audio src: ${src}`));
        cleanup();
      };

      try {
        audio.currentTime = 0;
        const playPromise = audio.play();

        if (fade) {
          fadeVolume(id, audio, 1, volume, fadeDuration, fadeCurve);
        }

        if (playPromise instanceof Promise) {
          playPromise.catch((e) => {
            onError?.(e);
            cleanup();
          });
        }

        instances.current.set(id, audio);
        return id;
      } catch (e) {
        onError?.(e instanceof Error ? e : new Error("Unknown error playing audio."));
        cleanup();
        return id;
      }
    },
    []
  );

  const stop = useCallback(
    (
      id: AudioInstanceId,
      fade = false,
      fadeDuration = defaultFadeDuration,
      fadeCurve: FadeCurve = "linear",
      onComplete?: () => void
    ) => {
      const audio = instances.current.get(id);
      if (!audio) {
        onComplete?.();
        return;
      }

      clearFadeTimeout(id);

      if (fade && audio.volume > 0) {
        const currentVolume = Math.round(audio.volume * 100);
        fadeVolume(id, audio, currentVolume, 1, fadeDuration, fadeCurve, () => {
          audio.pause();
          audio.remove();
          instances.current.delete(id);
          onComplete?.();
        });
      } else {
        audio.pause();
        audio.remove();
        instances.current.delete(id);
        onComplete?.();
      }
    },
    []
  );

  const stopAll = useCallback(
    (fade = false, fadeDuration = defaultFadeDuration, fadeCurve: FadeCurve = "linear") => {
      Array.from(instances.current.keys()).forEach((id) =>
        stop(id, fade, fadeDuration, fadeCurve)
      );
    },
    [stop]
  );

  const cleanupAll = useCallback(() => {
    stopAll(false);
  }, [stopAll]);

  const updateVolume = useCallback((id: AudioInstanceId, volume: number) => {
    const audio = instances.current.get(id);
    if (!audio) return;
    const volumeDecimal = Math.min(Math.max(volume / 100, 0), 1);
    audio.volume = volumeDecimal;
  }, []);

  useEffect(() => {
    return () => {
      fadeTimeouts.current.forEach((timeout) => clearTimeout(timeout));
      fadeTimeouts.current.clear();
      instances.current.forEach((audio) => {
        audio.pause();
        audio.remove();
      });
      instances.current.clear();
    };
  }, []);

  return { play, stop, stopAll, cleanupAll, updateVolume };
}

export { useUIAudio };

/**
 * Usage Examples:
 *
 * import useUIAudio from './useUIAudio';
 *
 * function MyComponent() {
 *   const { play, stop, stopAll } = useUIAudio();
 *   const soundIdRef = useRef<string | null>(null);
 *
 *   // Play a sound once at 80% volume with fade-in
 *   const handlePlaySound = () => {
 *     soundIdRef.current = play('/sounds/click.mp3', {
 *       fade: true,
 *       fadeDuration: 500,
 *       volume: 80, // 1-100 range
 *       onEnd: () => console.log('Sound ended'),
 *       onError: (err) => console.error('Audio error:', err),
 *     });
 *   };
 *
 *   // Stop the specific sound with fade-out
 *   const handleStopSound = () => {
 *     if (soundIdRef.current) {
 *       stop(soundIdRef.current, true, 500, 'exponential', () => {
 *         soundIdRef.current = null;
 *       });
 *     }
 *   };
 *
 *   // Stop all sounds
 *   const handleStopAll = () => {
 *     stopAll(true, 500, 'linear');
 *   };
 *
 *   return (
 *     <>
 *       <button onClick={handlePlaySound}>Play Sound</button>
 *       <button onClick={handleStopSound}>Stop Sound</button>
 *       <button onClick={handleStopAll}>Stop All Sounds</button>
 *     </>
 *   );
 * }
 */
