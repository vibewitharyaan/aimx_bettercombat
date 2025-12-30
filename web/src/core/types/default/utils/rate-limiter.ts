export interface RateLimiterConfig {
  readonly maxCalls: number;
  readonly timeWindow: number;
}

export interface RateLimiterInstance {
  readonly isRateLimited: () => boolean;
  readonly reset: () => void;
}

export type RateLimitFunction = () => boolean;
