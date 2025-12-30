import { memo } from 'react';
import { Group, Badge } from '@mantine/core';

const TECH_BADGES = [
  'React',
  'TypeScript',
  'Vite',
  'Tailwind',
  'Mantine',
  'Zustand',
  'Axios',
  'Biome',
  'Motion',
] as const;

const TechBadges = memo(() => (
  <Group gap="sm" justify="center" wrap="wrap" className="w-full max-w-md">
    {TECH_BADGES.map((tech) => (
      <Badge
        key={tech}
        variant="light"
        className="bg-primary/10 text-primary border border-primary/30 font-medium font-inter text-sm px-4 py-2 rounded-xl hover:bg-primary/15 hover:border-primary/50 hover:shadow-lg hover:shadow-primary/20 transition-all duration-300 cursor-default"
      >
        {tech}
      </Badge>
    ))}
  </Group>
));

export { TechBadges };
