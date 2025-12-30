import { Text } from '@mantine/core';
import { memo } from 'react';
import { useT } from '../../../shared/store/locale';

interface ExampleFooterProps {
  developerName: string;
  brandName: string;
}

const ExampleFooter = memo<ExampleFooterProps>(({ developerName, brandName }) => {
  const t = useT();

  return (
    <div className="w-full pt-6 mt-4">
      <div className="h-px bg-gradient-to-r from-transparent via-secondary/40 to-transparent mb-4" />
      <div className="bg-secondary/10 rounded-lg px-4 py-3">
        <Text className="text-sm text-white/75 font-medium font-inter text-center">
          {t('example.footer', { developerName, brandName }, `Made by ${developerName} | ${brandName}`)}
        </Text>
      </div>
    </div>
  );
});

export { ExampleFooter };
