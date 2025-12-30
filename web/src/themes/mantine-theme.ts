import { createTheme } from '@mantine/core';

const mantineTheme = createTheme({
  fontFamily: 'Inter, sans-serif',
  colors: {
    primary: [
      'var(--btn-primary)', // 50
      'var(--btn-primary)', // 100
      'var(--btn-primary)', // 200
      'var(--btn-primary)', // 300
      'var(--btn-primary)', // 400
      'var(--btn-primary)', // 500
      'var(--btn-primary-hover)', // 600
      'var(--btn-primary-hover)', // 700
      'var(--border-primary)', // 800
      'var(--border-primary)', // 900
    ],
  },
});

export default mantineTheme;
