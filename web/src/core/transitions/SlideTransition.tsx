import { AnimatePresence, motion } from "motion/react";
import { useEffect, useRef } from "react";
import type { SlideTransitionProps } from '../types/default/transitions/slide-transition';

export function SlideTransition({
  show,
  children,
  onHide,
  onShow,
  className = '',
  initialX = -420,
  animateX = 0,
  exitX = -420,
  position = 'fixed',
}: SlideTransitionProps) {
  const prevShowRef = useRef(show);

  useEffect(() => {
    if (show && !prevShowRef.current && onShow) {
      onShow();
    }
    prevShowRef.current = show;
  }, [show, onShow]);

  const positionStyles = position === 'fixed'
    ? { position: 'fixed' as const, left: 0, top: 0, height: '100%' }
    : position === 'absolute'
      ? { position: 'absolute' as const }
      : { position: 'relative' as const };

  return (
    <AnimatePresence initial={false} onExitComplete={onHide}>
      {show && (
        <motion.div
          key="slide-transition"
          initial={{ x: initialX, opacity: 0, ...positionStyles }}
          animate={{ x: animateX, opacity: 1, ...positionStyles }}
          exit={{ x: exitX, opacity: 0, ...positionStyles }}
          transition={{ duration: 0.4, ease: [0.4, 0, 0.2, 1] }}
          className={className}
          style={{ willChange: 'transform, opacity' }}
        >
          {children}
        </motion.div>
      )}
    </AnimatePresence>
  );
}
