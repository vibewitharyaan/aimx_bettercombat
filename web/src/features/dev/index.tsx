import { Button, Divider, Group, Menu, Paper, Switch, Text } from '@mantine/core';
import { useHotkeys } from '@mantine/hooks';
import { useCallback, useEffect, useMemo, useState } from 'react';
import { useThemeStore } from '../../shared/store/theme';
import { ScaleFade } from '../../core/transitions/ScaleFade';
import { createThemeMenuItems } from './debug/index.tsx';
import { getDebugConfigs } from './registry';
import './debug';

// CREDITS: These two images (day & night) by NoxenScripts, sourced from the Cfx.re forum
export const BACKGROUND_IMAGES = {
  DAY: 'https://i.postimg.cc/1RbCKvdJ/fivem-day.jpg',
  NIGHT: 'https://i.postimg.cc/668bRkM8/fivem-night.jpg',
} as const;

let currentBackgroundState: { isNight: boolean; customImage: string | null; } = {
  isNight: false,
  customImage: null,
};

const applyBackgroundImage = (imageUrl: string | null) => {
  const appWrapper = document.querySelector('.app-wrapper') as HTMLElement | null;
  if (!appWrapper) return;

  if (imageUrl) {
    Object.assign(appWrapper.style, {
      backgroundImage: `url(${imageUrl})`,
      backgroundSize: '100% 100%',
      backgroundPosition: 'center',
      backgroundRepeat: 'no-repeat',
    });
  } else {
    const defaultImage = currentBackgroundState.isNight ? BACKGROUND_IMAGES.NIGHT : BACKGROUND_IMAGES.DAY;
    Object.assign(appWrapper.style, {
      backgroundImage: `url(${defaultImage})`,
      backgroundSize: '100% 100%',
      backgroundPosition: 'center',
      backgroundRepeat: 'no-repeat',
    });
  }
};

export const setBackgroundImage = (imageUrl: string | null) => {
  currentBackgroundState.customImage = imageUrl;
  applyBackgroundImage(imageUrl);
};

export const restoreDefaultBackground = () => {
  currentBackgroundState.customImage = null;
  applyBackgroundImage(null);
};

const ICON_PROPS_DEFAULT = {
  width: 16,
  height: 16,
  strokeWidth: 2.5,
} as const;

type IconProps = React.SVGProps<SVGSVGElement> & typeof ICON_PROPS_DEFAULT;

const SunIcon = ({ width = 16, height = 16, strokeWidth = 2.5, ...props }: Partial<IconProps>) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 24 24"
    fill="none"
    stroke="var(--mantine-color-yellow-4)"
    strokeLinecap="round"
    strokeLinejoin="round"
    width={width}
    height={height}
    strokeWidth={strokeWidth}
    aria-hidden="true"
    focusable="false"
    {...props}
  >
    <circle cx="12" cy="12" r="4" />
    <path d="M3 12h1m8-9v1m8 8h1m-9 8v1m-6.4-15.4l.7.7m12.1-.7l-.7.7m0 11.4l.7.7m-12.1-.7l-.7.7" />
  </svg>
);

const MoonStarsIcon = ({ width = 16, height = 16, strokeWidth = 2.5, ...props }: Partial<IconProps>) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 24 24"
    fill="none"
    stroke="var(--mantine-color-blue-6)"
    strokeLinecap="round"
    strokeLinejoin="round"
    width={width}
    height={height}
    strokeWidth={strokeWidth}
    aria-hidden="true"
    focusable="false"
    {...props}
  >
    <path d="M12 3c.132 0 .263 0 .393 0a7.5 7.5 0 0 0 7.92 12.446 9 9 0 1 1-8.313-12.454z" />
    <path d="M17 4a2 2 0 0 0 2 2 2 2 0 0 0-2 2 2 2 0 0 0-2-2 2 2 0 0 0 2-2z" />
    <path d="M19 11h2m-1-1v2" />
  </svg>
);

function useDebugMenuItems (themes: readonly string[]) {
  const themeMenuItems = useMemo(() => createThemeMenuItems(themes), [themes]);
  const registeredConfigs = getDebugConfigs();

  return useMemo(
    () => [
      {
        label: 'Change Theme',
        subItems: themeMenuItems,
      },
      ...registeredConfigs,
    ],
    [themeMenuItems, registeredConfigs]
  );
}

export default function DevContainer () {
  const [isNight, setIsNight] = useState(false);
  const [isVisible, setIsVisible] = useState(true);

  const themes = useMemo(() => useThemeStore.getState().getValidThemes(), []);
  const menuItems = useDebugMenuItems(themes);

  const toggleNightMode = useCallback(() => {
    setIsNight((prev) => {
      const newState = !prev;
      currentBackgroundState.isNight = newState;
      if (!currentBackgroundState.customImage) {
        applyBackgroundImage(null);
      }
      return newState;
    });
  }, []);

  const toggleVisibility = useCallback(() => {
    setIsVisible((prev) => !prev);
  }, []);

  useEffect(() => {
    const appWrapper = document.querySelector('.app-wrapper') as HTMLElement | null;
    if (!appWrapper) return;

    currentBackgroundState.isNight = isNight;
    const imageUrl = currentBackgroundState.customImage
      ? currentBackgroundState.customImage
      : isNight
        ? BACKGROUND_IMAGES.NIGHT
        : BACKGROUND_IMAGES.DAY;

    const styles = {
      backgroundImage: `url(${imageUrl})`,
      backgroundSize: '100% 100%',
      backgroundPosition: 'center',
      backgroundRepeat: 'no-repeat',
    };

    Object.assign(appWrapper.style, styles);

    return () => {
      for (const key of Object.keys(styles)) {
        (appWrapper.style as any)[key] = '';
      }
    };
  }, [isNight]);

  useHotkeys([['f2', toggleVisibility]]);

  return (
    <div
      className="fixed inset-0 pointer-events-none z-[99999] flex justify-center items-start font-sans"
      aria-live="polite"
      aria-atomic="true"
      aria-relevant="additions text"
    >
      <ScaleFade show={isVisible} className="mt-5">
        <Paper
          shadow="md"
          radius="md"
          className="pointer-events-auto bg-zinc-900 border border-zinc-600 py-0 px-3"
        >
          <Group gap="0.5rem" align="center">
            <Switch
              color="dark.4"
              checked={isNight}
              onChange={toggleNightMode}
              onLabel={<SunIcon aria-label="Switch to day mode" />}
              offLabel={<MoonStarsIcon aria-label="Switch to night mode" />}
              aria-label={isNight ? 'Switch to day mode' : 'Switch to night mode'}
            />

            <Divider
              size="xs"
              orientation="vertical"
              className="h-3 opacity-50 bg-zinc-900 my-auto"
            />

            <Menu position="bottom-start" withinPortal={false} offset={0.625}>
              <Menu.Target>
                <Button
                  variant="transparent"
                  color="dark.1"
                  size="md"
                  className="px-1 font-sans font-medium"
                  aria-haspopup="true"
                >
                  Debug Events
                </Button>
              </Menu.Target>

              <Menu.Dropdown className="bg-zinc-900 text-white border border-zinc-600 mt-1">
                {menuItems.map((item) => (
                  <Menu.Sub key={item.label}>
                    <Menu.Sub.Target>
                      <Menu.Sub.Item
                        className="text-white hover:bg-zinc-700 border-zinc-600 font-sans"
                        aria-haspopup="true"
                      >
                        <Text fw={500} size="md" c="dark.1" className="font-sans">
                          {item.label}
                        </Text>
                      </Menu.Sub.Item>
                    </Menu.Sub.Target>

                    <Menu.Sub.Dropdown className="bg-zinc-900 text-white border border-zinc-600">
                      {item.subItems.map((sub) => (
                        <Menu.Item
                          key={sub.label}
                          onClick={sub.onClick}
                          className="text-white hover:bg-zinc-700 border-zinc-600 font-sans"
                        >
                          <Text fw={500} size="md" c="dark.1" className="font-sans">
                            {sub.label}
                          </Text>
                        </Menu.Item>
                      ))}
                    </Menu.Sub.Dropdown>
                  </Menu.Sub>
                ))}
              </Menu.Dropdown>
            </Menu>
          </Group>
        </Paper>
      </ScaleFade>
    </div>
  );
}
