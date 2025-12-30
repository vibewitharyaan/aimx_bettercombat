import type { ReactNode } from 'react';

export interface ScreenFadeProps {
  readonly isVisible: boolean;
  readonly duration?: number;
  readonly onShowStart?: () => void;
  readonly onShowComplete?: () => void;
  readonly onHideStart?: () => void;
  readonly onHideComplete?: () => void;
  readonly overlayClassName?: string;
  readonly children?: ReactNode;
  readonly zIndex?: number;
}
