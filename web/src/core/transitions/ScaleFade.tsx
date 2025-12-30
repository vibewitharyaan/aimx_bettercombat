import { AnimatePresence, motion } from "motion/react";
import { useEffect, useRef } from "react";
import type { ScaleFadeProps } from '../types/default/transitions/scale-fade';

export function ScaleFade ({ show, children, onHide, onShow, className }: ScaleFadeProps) {
  const prevShowRef = useRef(show);

  useEffect(() => {
    if (show && !prevShowRef.current && onShow) {
      onShow();
    }
    prevShowRef.current = show;
  }, [show, onShow]);

  return (
    <AnimatePresence initial={false} onExitComplete={onHide}>
      {show && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.25, ease: "easeOut" }}
          className={`${className || ''}`}
          style={{ willChange: 'opacity' }}
        >
          {children}
        </motion.div>
      )}
    </AnimatePresence>
  );
}
