import { Text } from '@mantine/core';
import { memo } from 'react';
import { useT } from '../../../shared/store/locale';
import { assets } from '../../../core/utils/assets';

interface ExampleHeaderProps {
  brandName: string;
}

const ExampleHeader = memo<ExampleHeaderProps>(({ brandName }) => {
  const t = useT();

  return (
    <>
      <img
        src={assets.images.logo}
        alt="ERROR HUB LOGO"
        className="h-24 w-auto"
      />

      <div className="space-y-3">
        <Text className="text-3xl font-bold text-white/95 font-accent tracking-tight">
          {t('example.title', { brandName }, `Welcome to ${brandName} FiveM`)}
        </Text>
        <div className="h-px bg-gradient-to-r from-transparent via-primary/50 to-transparent w-32 mx-auto" />
      </div>
    </>
  );
});

export { ExampleHeader };
