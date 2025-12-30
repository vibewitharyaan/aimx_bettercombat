import type { ReactNode } from 'react';

export interface ScaleFadeProps {
  readonly show: boolean;
  readonly children: ReactNode;
  readonly onHide?: () => void;
  readonly onShow?: () => void;
  readonly className?: string;
}
