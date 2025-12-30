import axios from 'axios';
import { useEffect, useRef } from 'react';
import { isEnvBrowser, noop } from './misc';
import type { NuiMessageData, NuiHandlerSignature, FetchNuiResult } from '../types/default/utils/bridge';

const IS_DEV_BROWSER = isEnvBrowser();
const RESOURCE_NAME = ('GetParentResourceName' in window)
  ? (window as unknown as { GetParentResourceName: () => string; }).GetParentResourceName()
  : 'nui-frame-app';

const nuiAxios = axios.create({
  timeout: 10000,
  headers: { 'Content-Type': 'application/json' }
});

const RATE_LIMIT_WINDOW = 1000;
const MAX_CALLS_PER_WINDOW = 10;
const MAX_HISTORY_ENTRIES = 100;
const callHistory = new Map<string, number[]>();
const lastAccess = new Map<string, number>();

function validateEventName (eventName: string): string {
  if (!/^[a-zA-Z0-9_:-]+$/.test(eventName)) {
    throw new Error(`Invalid event name: "${eventName}". Only alphanumeric, underscore, dash, and colon allowed.`);
  }
  return eventName;
}

function evictOldestEntry (): void {
  const [oldestKey] = [...lastAccess.entries()].reduce((a, b) => a[1] < b[1] ? a : b);
  callHistory.delete(oldestKey);
  lastAccess.delete(oldestKey);
}

function isRateLimited (eventName: string): boolean {
  const now = Date.now();
  const calls = (callHistory.get(eventName) || []).filter(t => now - t < RATE_LIMIT_WINDOW);

  if (calls.length >= MAX_CALLS_PER_WINDOW) {
    callHistory.set(eventName, calls);
    lastAccess.set(eventName, now);
    return true;
  }

  if (!callHistory.has(eventName) && callHistory.size >= MAX_HISTORY_ENTRIES) {
    evictOldestEntry();
  }

  calls.push(now);
  callHistory.set(eventName, calls);
  lastAccess.set(eventName, now);
  return false;
}

export async function fetchNui<T = unknown> (eventName: string, data?: unknown): Promise<FetchNuiResult<T>> {
  const safeEventName = validateEventName(eventName);

  if (IS_DEV_BROWSER) {
    console.log(
      `%c[Nui-Post]%c ${safeEventName}`,
      'color: #4CAF50; font-weight: bold',
      'color: inherit',
      data ?? '(no data)'
    );
    return { ok: true };
  }

  if (isRateLimited(safeEventName)) {
    console.warn(`Rate limited: ${safeEventName} - too many calls`);
    return { ok: false };
  }

  const url = `https://${RESOURCE_NAME}/${safeEventName}`;

  try {
    const response = await nuiAxios.post(url, data);
    return { ok: true, data: response.data ?? undefined };
  } catch (error) {
    console.error(`fetchNui error for event "${safeEventName}":`, error);
    return { ok: false };
  }
}

export function useNuiEvent<T = unknown> (action: string, handler: NuiHandlerSignature<T>) {
  const savedHandler = useRef<NuiHandlerSignature<T>>(noop);

  useEffect(() => {
    savedHandler.current = handler;
  }, [handler]);

  useEffect(() => {
    const eventListener = (event: MessageEvent<NuiMessageData<T>>) => {
      if (event.data?.action === action) {
        if (IS_DEV_BROWSER) {
          console.log(
            `%c[Nui-Message]%c ${action}`,
            'color: #3496e5; font-weight: bold',
            'color: inherit',
            event.data.data ?? '(no data)'
          );
        }
        savedHandler.current(event.data.data);
      }
    };

    window.addEventListener('message', eventListener);
    return () => window.removeEventListener('message', eventListener);
  }, [action]);
}

/**
 * Examples of usage in FiveM scenarios:
 *
 * 1. Simple notification:
 *    // Trigger and ignore the result (optional await if you need to sequence)
 *    fetchNui('toggle_inventory');
 *
 *
 * 2. Send data without needing the response:
 *    fetchNui('create_blip', { x: 640, y: 360 });
 *
 *
 * 3. Send data and expect typed response:
 *    interface PurchaseResult { success: boolean; itemId: string; }
 *
 *    const result = await fetchNui<PurchaseResult>('purchase_item', {
 *      itemName: 'weapon_pistol',
 *      quantity: 1,
 *    });
 *
 *    if (result.ok && result.data) {
 *      console.log(`Purchased ${result.data.itemId}`);
 *    } else {
 *      console.error('Purchase failed');
 *    }
 *
 *
 * 4. Get data without sending anything:
 *    interface PlayerStats {
 *      health: number;
 *      armor: number;
 *      money: number;
 *    }
 *
 *    const stats = await fetchNui<PlayerStats>('get_player_stats');
 *
 *    if (stats.ok && stats.data) {
 *      updateHUD(stats.data);
 *    } else {
 *      showError('Failed to load stats');
 *    }
 *
 *
 * 5. Typical component usage:
 *    const handleInventoryOpen = async () => {
 *      await fetchNui('open_inventory');
 *      const inv = await fetchNui<InventoryData>('get_inventory_items');
 *
 *      if (inv.ok && inv.data) {
 *         setInventoryItems(inv.data.items);
 *         setInventoryOpen(true);
 *      } else {
 *         showNotification('Cannot load inventory', 'error');
 *      }
 *    };
 */

/**
 * Examples of usage in FiveM scenarios:
 *
 * 1. Listen for an action to open the inventory:
 *
 *    useNuiEvent('open_inventory', () => {
 *      openInventory();
 *    });
 *
 *
 * 2. Listen for an event with data payload to update the player HUD:
 *
 *    interface PlayerHUD {
 *      health: number;
 *      armor: number;
 *      thirst: number;
 *      hunger: number;
 *    }
 *
 *    useNuiEvent<PlayerHUD>('update_player_hud', (hud) => {
 *      if (hud) {
 *        updateHealthBar(hud.health);
 *        updateArmorBar(hud.armor);
 *        updateThirstBar(hud.thirst);
 *        updateHungerBar(hud.hunger);
 *      }
 *    });
 */
