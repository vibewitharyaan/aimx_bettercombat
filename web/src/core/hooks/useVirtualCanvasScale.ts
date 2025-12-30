import { useEffect, useRef } from 'react';

const REFERENCE_WIDTH = 1920;
const REFERENCE_HEIGHT = 1080;
const RESIZE_DEBOUNCE_MS = 100;

export function useVirtualCanvasScale(): void {
  const timeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => {
    const updateScale = () => {
      const scaleX = window.innerWidth / REFERENCE_WIDTH;
      const scaleY = window.innerHeight / REFERENCE_HEIGHT;

      document.documentElement.style.setProperty('--app-scale-x', String(scaleX));
      document.documentElement.style.setProperty('--app-scale-y', String(scaleY));
    };

    // set initial scale
    updateScale();

    const handleResize = () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }

      timeoutRef.current = setTimeout(updateScale, RESIZE_DEBOUNCE_MS);
    };

    window.addEventListener('resize', handleResize);

    return () => {
      window.removeEventListener('resize', handleResize);
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
    };
  }, []);
}

