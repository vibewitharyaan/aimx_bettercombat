import '@mantine/core/styles.css';
import { MantineProvider } from '@mantine/core';
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { App } from './App';
import './index.css';
import ErrorBoundary from './core/providers/ErrorBoundary';
import mantineTheme from './themes/mantine-theme';

const root = document.getElementById('root');

if (!root) {
  throw new Error('Root element not found. Make sure #root exists in index.html');
}

createRoot(root!).render(
  <StrictMode>
    <MantineProvider theme={mantineTheme}>
      <ErrorBoundary>
        <App />
      </ErrorBoundary>
    </MantineProvider>
  </StrictMode>
);
