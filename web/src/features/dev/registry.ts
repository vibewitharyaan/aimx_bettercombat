export interface DebugMenuItem {
  label: string;
  onClick: () => void;
}

export interface DebugMenuConfig {
  label: string;
  subItems: DebugMenuItem[];
}

const debugConfigs: DebugMenuConfig[] = [];

export function registerDebugConfig (config: DebugMenuConfig): void {
  if (debugConfigs.some((c) => c.label === config.label)) return;
  debugConfigs.push(config);
}

export function getDebugConfigs (): readonly DebugMenuConfig[] {
  return debugConfigs;
}

