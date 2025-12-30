import type { ReactNode } from 'react';

export interface SlideTransitionProps {
  readonly show: boolean;
  readonly children: ReactNode;
  readonly onHide?: () => void;
  readonly onShow?: () => void;
  readonly className?: string;
  readonly initialX?: number | string;
  readonly animateX?: number | string;
  readonly exitX?: number | string;
  readonly position?: 'fixed' | 'relative' | 'absolute';
}
