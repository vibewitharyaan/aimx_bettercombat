export interface NuiMessageData<T = unknown> {
  readonly action: string;
  readonly data?: T;
}

export type NuiHandlerSignature<T> = (data?: T) => void;

export interface FetchNuiResult<T = unknown> {
  readonly ok: boolean;
  readonly data?: T;
}
