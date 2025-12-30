import type { RateLimiterConfig, RateLimiterInstance, RateLimitFunction } from '../types/default/utils/rate-limiter';

export class RateLimiter implements RateLimiterInstance {
  private calls: number[] = [];
  private readonly maxCalls: number;
  private readonly timeWindow: number;

  constructor(config: RateLimiterConfig) {
    if (config.maxCalls <= 0 || config.timeWindow <= 0) {
      throw new Error('maxCalls and timeWindow must be positive numbers');
    }
    this.maxCalls = config.maxCalls;
    this.timeWindow = config.timeWindow;
  }

  isRateLimited (): boolean {
    const now = Date.now();

    let i = 0;
    while (i < this.calls.length && now - this.calls[i] >= this.timeWindow) {
      i++;
    }
    this.calls.splice(0, i);

    if (this.calls.length >= this.maxCalls) {
      return true;
    }

    this.calls.push(now);
    return false;
  }

  reset (): void {
    this.calls = [];
  }
}

export function rateLimit (config: RateLimiterConfig): RateLimitFunction {
  const limiter = new RateLimiter(config);
  return () => limiter.isRateLimited();
}

// Convenience function for quick setup
export function createRateLimiter (maxCalls: number, timeWindow: number): RateLimiter {
  return new RateLimiter({ maxCalls, timeWindow });
}

/**
 * Usage Examples:
 *
 * // Persistent instance for rate limiting (recommended)
 * const limiter = new RateLimiter({ maxCalls: 5, timeWindow: 1000 }); // 5 calls per second
 * if (limiter.isRateLimited()) return;
 *
 * // Convenience function for quick setup
 * const quickLimiter = createRateLimiter(5, 1000); // Same as above, shorter syntax
 * if (quickLimiter.isRateLimited()) return;
 *
 * // React component with useMemo
 * const buttonLimiter = useMemo(() => createRateLimiter(3, 1000), []); // 3 clicks per second
 * if (buttonLimiter.isRateLimited()) return;
 *
 * // One-time check (creates new instance each call)
 * const isRateLimited = rateLimit({ maxCalls: 10, timeWindow: 1000 }); // 10 calls per second
 * if (isRateLimited()) return;
 *
 * // Using config object for clarity
 * const apiLimiter = new RateLimiter({
 *   maxCalls: 100,
 *   timeWindow: 60000 // 100 calls per minute
 * });
 *
 * // Your action here - only executes if not rate limited
 * if (!apiLimiter.isRateLimited()) {
 *   makeApiCall();
 * }
 *
 * // Reset when needed
 * limiter.reset();
 */
