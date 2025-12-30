import { Button } from '@mantine/core';
import { memo, useCallback, useMemo } from 'react';
import { useUIAudio } from '../../../core/hooks/useSound';
import { useT } from '../../../shared/store/locale';
import { assets } from '../../../core/utils/assets';
import { fetchNui } from '../../../core/utils/bridge';
import { createRateLimiter } from '../../../core/utils/rateLimiter';
import type { StartExamplePayload } from '../types';

interface ExampleCTAButtonProps {
  developerName: string;
}

const ExampleCTAButton = memo<ExampleCTAButtonProps>(({ developerName }) => {
  const { play } = useUIAudio();
  const t = useT();

  const buttonLimiter = useMemo(() => createRateLimiter(2, 1000), []);

  const onButtonClick = useCallback(async () => {
    if (buttonLimiter.isRateLimited()) return console.log("Please don't spam");

    play(assets.audio.click, { volume: 40 });

    const payload: StartExamplePayload = { name: developerName };
    fetchNui('example:start', payload);
  }, [developerName, play, buttonLimiter]);

  return (
    <Button
      size="xl"
      className="group bg-primary hover:bg-primary/90 text-white font-bold font-inter px-12 py-4 rounded-2xl shadow-btn hover:shadow-primary/40 transition-all duration-300 border border-primary/30 hover:border-primary/50"
      onClick={onButtonClick}
    >
      <span className="flex items-center gap-3">
        {t('example.button', 'Start Building')}
        <svg className="w-5 h-5 group-hover:translate-x-1 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7l5 5m0 0l-5 5m5-5H6" />
        </svg>
      </span>
    </Button>
  );
});

export { ExampleCTAButton };
