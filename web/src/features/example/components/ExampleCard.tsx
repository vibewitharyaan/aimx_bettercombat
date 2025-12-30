import { memo, type ReactNode } from 'react';
import { Paper } from '@mantine/core';

interface ExampleCardProps {
  children: ReactNode;
}

const ExampleCard = memo<ExampleCardProps>(({ children }) => (
  <Paper
    shadow="xl"
    radius="xl"
    className="w-[32rem] bg-secondary border-2 border-secondary/30 overflow-hidden relative"
  >
    <div className="absolute inset-0 rounded-2xl bg-gradient-to-r from-primary/10 via-primary/5 to-primary/10 p-[1px]">
      <div className="w-full h-full bg-secondary/20 rounded-2xl" />
    </div>
    <div className="relative z-10 p-12">{children}</div>
  </Paper>
));

export { ExampleCard };
