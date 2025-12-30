import { Stack, Text } from '@mantine/core';
import { memo, useState } from 'react';
import { ScaleFade } from '../../core/transitions/ScaleFade';
import { useExampleStore } from './store';
import { useNuiEvent } from '../../core/utils/bridge';
import { useUIAudio } from '../../core/hooks/useSound';
import { assets } from '../../core/utils/assets';
import { useT } from '../../shared/store/locale';
import { ExampleCard, ExampleCTAButton, ExampleFooter, ExampleHeader, TechBadges } from './components';
import type { ToggleVisibilityPayload, UpdateCardPayload } from './types';

const Example = () => {
  const [brandName, setBrandName] = useState('Brand Name');
  const [developerName, setDeveloperName] = useState('Dev Name');

  const isVisible = useExampleStore((s) => s.isVisible);
  const setVisibility = useExampleStore((s) => s.setVisibility);

  const { play } = useUIAudio();
  const t = useT();

  const handleToggleVisibility = (show: boolean) => {
    setVisibility(show);

    if (show) {
      play(assets.audio.click, { volume: 5 });
    }
  };

  useNuiEvent<ToggleVisibilityPayload>('example:toggle', (data) => {
    const show = data?.show;
    handleToggleVisibility(Boolean(show));
  });

  useNuiEvent<UpdateCardPayload>('example:update_card', (data) => {
    if (data?.brandName) setBrandName(data.brandName);
    if (data?.developerName) setDeveloperName(data.developerName);
  });

  return (
    <ScaleFade
      show={isVisible}
      className="fixed inset-0 flex items-center justify-center bg-transparent font-sans"
    >
      <ExampleCard>
        <Stack gap="xl" align="center" ta="center">
          <ExampleHeader brandName={brandName} />

          <Stack gap="lg" align="center" className="w-full">
            <Text className="text-xl font-medium text-white/90 font-inter tracking-wide">
              {t('example.subtitle', 'UI Boilerplate')}
            </Text>

            <TechBadges />

            <Text className="text-base text-white/80 font-inter leading-relaxed max-w-lg text-center">
              {t('example.desc', 'Built with React, TypeScript & Tailwind — ready to go!')}
            </Text>

            <ExampleCTAButton developerName={developerName} />
          </Stack>

          <ExampleFooter developerName={developerName} brandName={brandName} />
        </Stack>
      </ExampleCard>
    </ScaleFade>
  );
};

export const ExampleComponent = memo(Example);
