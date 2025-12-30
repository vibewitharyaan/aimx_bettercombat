import { AnimatePresence, motion, type Variants } from 'motion/react';
import { memo, useCallback } from 'react';
import type { ScreenFadeProps } from '../types/default/transitions/screen-fade';

const overlayVariants: Variants = {
  hidden: {
    opacity: 0,
    transition: { ease: 'easeInOut' }
  },
  visible: {
    opacity: 1,
    transition: { ease: 'easeInOut' }
  },
};

const DESIGN_TOKENS = {
  DEFAULT_DURATION: 500,
  DEFAULT_Z_INDEX: 50,
  OVERLAY_COLOR: 'bg-black',
} as const;

const ScreenFade = memo<ScreenFadeProps>(({
  isVisible,
  duration = DESIGN_TOKENS.DEFAULT_DURATION,
  onShowStart,
  onShowComplete,
  onHideStart,
  onHideComplete,
  overlayClassName = '',
  children,
  zIndex = DESIGN_TOKENS.DEFAULT_Z_INDEX,
}) => {
  const durationInSeconds = duration / 1000;

  const handleAnimationStart = useCallback(() => {
    if (isVisible) {
      onShowStart?.();
    } else {
      onHideStart?.();
    }
  }, [isVisible, onShowStart, onHideStart]);

  const handleAnimationComplete = useCallback(() => {
    if (isVisible) {
      onShowComplete?.();
    } else {
      onHideComplete?.();
    }
  }, [isVisible, onShowComplete, onHideComplete]);

  const transition = {
    duration: durationInSeconds,
    ease: 'easeInOut' as const,
  };

  return (
    <div
      className="fixed inset-0 w-full h-full flex items-center justify-center"
      style={{ zIndex: zIndex - 10 }}
      role="presentation"
    >
      {children}

      <AnimatePresence mode="wait">
        <motion.div
          key="screen-fade-overlay"
          initial="hidden"
          animate={isVisible ? "visible" : "hidden"}
          exit="hidden"
          variants={overlayVariants}
          transition={transition}
          onAnimationStart={handleAnimationStart}
          onAnimationComplete={handleAnimationComplete}
          className={`
            fixed inset-0 pointer-events-none
            ${DESIGN_TOKENS.OVERLAY_COLOR}
            ${overlayClassName}
          `.trim().replace(/\s+/g, ' ')}
          style={{ zIndex }}
          aria-hidden="true"
          role="presentation"
        />
      </AnimatePresence>
    </div>
  );
});

export default ScreenFade;

/**
 * Usage Example:
 *
 * <ScreenFade
 *   isVisible={showOverlay}
 *   duration={1000}
 *   onShowComplete={() => console.log('Faded to black')}
 *   onHideComplete={() => console.log('Faded to transparent')}
 * >
 *   <MyContent />
 * </ScreenFade>
 */
