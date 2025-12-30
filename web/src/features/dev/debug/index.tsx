import { debugData } from '../../../core/utils/debugData';
import enLocale from '../../../../../locales/en.json';

export function debugInit (theme?: string | null) {
  debugData([
    {
      action: 'init',
      data: {
        locale: enLocale.ui,
        theme: theme || 'custom'
      },
    },
  ]);
}

export function createThemeMenuItems (themes: readonly string[]) {
  return themes.map((theme) => ({
    label: theme.charAt(0).toUpperCase() + theme.slice(1),
    onClick: () => debugInit(theme),
  }));
}
