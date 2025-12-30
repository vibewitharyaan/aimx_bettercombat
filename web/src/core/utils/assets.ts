import type { PreloaderFunction } from '../types/default/utils/assets';

export const assets = {
  images: {
    logo: '/images/logo.png',
  },
  audio: {
    click: '/audio/click.mp3',
  },
  icons: {},
} as const;

export const images = assets.images;
export const audio = assets.audio;
export const icons = assets.icons;

const preloadImage: PreloaderFunction = (src: string) => new Promise<void>((resolve, reject) => {
  const img = new Image();
  img.onload = () => resolve();
  img.onerror = () => reject(new Error(`Failed to load: ${src}`));
  img.src = src;
});

const preloadAudio: PreloaderFunction = (src: string) => new Promise<void>((resolve, reject) => {
  const audio = new Audio();
  audio.oncanplaythrough = () => resolve();
  audio.onerror = () => reject(new Error(`Failed to load: ${src}`));
  audio.preload = 'auto';
  audio.src = src;
  audio.load();
});

const collectSrcs = (obj: unknown): string[] => {
  if (typeof obj === 'string') return [obj];
  if (obj && typeof obj === 'object') return Object.values(obj).flatMap(collectSrcs);
  return [];
};

export const preloadAssets = async (): Promise<boolean> => {
  const tasks = [
    ...collectSrcs(images).map(src => preloadImage(src).catch(() => { })),
    ...Object.values(audio).map((src: string) => preloadAudio(src).catch(() => { })),
    ...collectSrcs(icons).map(src => preloadImage(src).catch(() => { })),
  ];
  await Promise.all(tasks);
  document.documentElement.classList.add('assets-loaded');
  return true;
};
