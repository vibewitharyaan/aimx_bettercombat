import { debugData } from '../../../core/utils/debugData';
import { useExampleStore } from '../../example/store';
import type { ToggleVisibilityPayload, UpdateCardPayload } from '../../example/types';
import { registerDebugConfig } from '../registry';

const debugExampleToggle = () => {
  const show = useExampleStore.getState().isVisible;
  debugData<ToggleVisibilityPayload>([
    {
      action: 'example:toggle',
      data: { show: !show },
    },
  ]);
};

const debugExampleUpdate = () => {
  debugData<UpdateCardPayload>([
    {
      action: 'example:update_card',
      data: { brandName: 'ERROR HUB', developerName: '3RROR' },
    },
  ]);
};

registerDebugConfig({
  label: 'Example',
  subItems: [
    { label: 'Toggle', onClick: debugExampleToggle },
    { label: 'Update Card', onClick: debugExampleUpdate },
  ],
});
