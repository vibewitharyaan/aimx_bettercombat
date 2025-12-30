/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      fontFamily: {
        primary: ['Inter', 'sans-serif'],
        secondary: ['Manrope', 'sans-serif'],
        accent: ['Poppins', 'sans-serif'],
        display: ['Satisfy', 'serif'],
        mono: ['JetBrains Mono', 'monospace'],
      },
      colors: {
        primary: 'hsla(var(--primary), <alpha-value>)',
        secondary: 'hsla(var(--secondary), <alpha-value>)',
      },
      boxShadow: {
        primary: "0 2px 8px 0 hsla(var(--primary), 0.35)",
        btn: "0 4px 14px 2px hsla(var(--primary), 0.18)",
      },
      ringColor: {
        focus: "hsla(var(--primary), 0.6)",
      },
      borderRadius: {
        DEFAULT: "0.5rem",
      },
    },
  },
  plugins: [
    ({ addUtilities, theme }) => {
      const utilities = {};
      for (const [key, value] of Object.entries(theme('textShadow', {}))) {
        utilities[`.text-shadow-${key}`] = { textShadow: value };
      }
      for (const [key, value] of Object.entries(theme('filter', {}))) {
        utilities[`.filter-${key}`] = { filter: value };
      }
      addUtilities(utilities);
    },
  ],
};
