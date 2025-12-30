import { Component, type ErrorInfo, createRef } from 'react';
import type {
  ErrorBoundaryProps,
  ErrorBoundaryState,
} from '../types/default/providers/error-boundary';

class ErrorBoundary extends Component<ErrorBoundaryProps, ErrorBoundaryState> {
  private retryButtonRef = createRef<HTMLButtonElement>();
  private toastTimeout: NodeJS.Timeout | null = null;

  constructor(props: ErrorBoundaryProps) {
    super(props);
    this.state = { hasError: false, error: null, copied: false };
  }

  static getDerivedStateFromError (error: Error): Partial<ErrorBoundaryState> {
    return { hasError: true, error };
  }

  componentDidCatch (error: Error, errorInfo: ErrorInfo) {
    this.props.onError?.(error, errorInfo);

    if (process.env.NODE_ENV === 'development') {
      console.error('ErrorBoundary caught an error:', error, errorInfo);
    }
  }

  componentDidUpdate (prevProps: ErrorBoundaryProps) {
    const { resetKeys } = this.props;
    const { hasError } = this.state;

    if (hasError && resetKeys && prevProps.resetKeys !== resetKeys) {
      const hasChanged =
        resetKeys.length !== (prevProps.resetKeys?.length || 0) ||
        resetKeys.some((key: string | number, idx: number) => key !== prevProps.resetKeys?.[idx]);

      if (hasChanged) {
        this.setState({ hasError: false, error: null, copied: false });
        // Focus retry button if re-rendered after reset
        this.retryButtonRef.current?.focus();
      }
    }
  }

  componentWillUnmount () {
    if (this.toastTimeout) {
      clearTimeout(this.toastTimeout);
    }
  }

  private handleRetry = () => {
    this.setState({ hasError: false, error: null, copied: false });
  };

  private copyErrorToClipboard = async () => {
    const { error } = this.state;
    if (!error) return;

    let text = `${error.name}: ${error.message}`;
    if (error.stack && process.env.NODE_ENV === 'development') {
      text += `\n\nStack:\n${error.stack}`;
    }

    try {
      await navigator.clipboard.writeText(text);
      this.setState({ copied: true });
      this.toastTimeout = setTimeout(() => {
        this.setState({ copied: false });
      }, 2000);
    } catch (err) {
      // Fallback for older browsers or clipboard permission issues
      const textarea = document.createElement('textarea');
      textarea.value = text;
      textarea.setAttribute('readonly', '');
      textarea.style.position = 'absolute';
      textarea.style.left = '-9999px';
      document.body.appendChild(textarea);
      textarea.select();
      try {
        document.execCommand('copy');
        this.setState({ copied: true });
        this.toastTimeout = setTimeout(() => {
          this.setState({ copied: false });
        }, 2000);
      } catch (e) {
        console.warn('Failed to copy error:', e);
      }
      document.body.removeChild(textarea);
    }
  };

  render () {
    const { hasError, error, copied } = this.state;
    const { children, fallback } = this.props;

    if (!hasError) return children;

    if (fallback) return fallback;

    return (
      <div
        className="fixed inset-0 bg-black/95 z-[9999] flex items-center justify-center p-4"
        role="alertdialog"
        aria-labelledby="error-dialog-title"
        aria-describedby="error-dialog-description"
      >
        <div className="bg-zinc-950 border border-zinc-800 rounded-xl shadow-2xl max-w-lg w-full p-6">
          <div className="text-center">
            <div className="w-12 h-12 bg-red-500/10 border border-red-500/20 rounded-xl flex items-center justify-center mx-auto mb-4">
              <svg
                className="w-6 h-6 text-red-400"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                aria-hidden="true"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M12 9v2m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
            </div>

            <h2 id="error-dialog-title" className="text-xl font-semibold text-zinc-100 mb-2">
              Something went wrong
            </h2>
            <p id="error-dialog-description" className="text-zinc-400 text-sm mb-6">
              The application encountered an unexpected error.
            </p>

            {process.env.NODE_ENV === 'development' && error && (
              <div className="bg-zinc-900 border border-zinc-800 rounded-lg p-4 mb-6 text-left">
                <div className="flex justify-between items-start mb-2">
                  <p className="text-red-400 text-sm font-mono break-words">{error.name}</p>
                  <button
                    onClick={this.copyErrorToClipboard}
                    className="ml-2 px-2 py-1 text-xs text-zinc-400 hover:text-zinc-200 bg-zinc-800 hover:bg-zinc-700 rounded transition-colors flex items-center gap-1"
                    aria-label="Copy error to clipboard"
                    title="Copy error"
                  >
                    {copied ? (
                      <>
                        <svg
                          className="w-3 h-3 text-green-400"
                          fill="none"
                          stroke="currentColor"
                          viewBox="0 0 24 24"
                        >
                          <path
                            strokeLinecap="round"
                            strokeLinejoin="round"
                            strokeWidth={3}
                            d="M5 13l4 4L19 7"
                          />
                        </svg>
                        Copied!
                      </>
                    ) : (
                      <>
                        <svg
                          className="w-3 h-3"
                          fill="none"
                          stroke="currentColor"
                          viewBox="0 0 24 24"
                        >
                          <path
                            strokeLinecap="round"
                            strokeLinejoin="round"
                            strokeWidth={2}
                            d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z"
                          />
                        </svg>
                        Copy
                      </>
                    )}
                  </button>
                </div>

                <p className="text-zinc-300 text-xs mt-1 break-words font-mono">{error.message}</p>

                {error.stack && (
                  <details className="mt-3 group open:border-zinc-700 border border-transparent rounded transition-colors">
                    <summary className="text-xs text-zinc-500 hover:text-zinc-300 cursor-pointer list-none [&::-webkit-details-marker]:hidden flex items-center justify-between">
                      <span>Show stack trace</span>
                      <svg
                        className="w-4 h-4 transform transition-transform group-open:rotate-90"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                      >
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          strokeWidth={2}
                          d="M9 5l7 7-7 7"
                        />
                      </svg>
                    </summary>
                    <pre className="mt-2 p-3 bg-zinc-950 text-zinc-400 text-[10px] rounded overflow-x-auto max-h-32">
                      {error.stack}
                    </pre>
                  </details>
                )}
              </div>
            )}

            <div className="flex flex-wrap gap-3 justify-center">
              <button
                ref={this.retryButtonRef}
                onClick={this.handleRetry}
                className="px-4 py-2 bg-zinc-100 hover:bg-white text-zinc-900 text-sm font-medium rounded-lg transition-colors focus:outline-none focus:ring-2 focus:ring-zinc-400 focus:ring-opacity-75"
                autoFocus
              >
                Try Again
              </button>
              <button
                onClick={() => window.location.reload()}
                className="px-4 py-2 bg-transparent hover:bg-zinc-800 text-zinc-400 hover:text-zinc-200 text-sm font-medium border border-zinc-700 hover:border-zinc-600 rounded-lg transition-colors focus:outline-none focus:ring-2 focus:ring-zinc-500"
              >
                Reload Page
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

export default ErrorBoundary;
