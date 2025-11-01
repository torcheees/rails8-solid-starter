/** @type {import('tailwindcss').Config} */
module.exports = {
  // Enable dark mode with class strategy (like Notion)
  darkMode: 'class',

  content: [
    './web/app/views/**/*.{html,haml,erb}',
    './web/app/helpers/**/*.rb',
    './web/app/javascript/**/*.{js,jsx,ts,tsx}'
  ],

  theme: {
    extend: {
      // Notion-inspired color palette
      colors: {
        // Light mode colors
        notion: {
          bg: '#ffffff',
          'bg-secondary': '#f7f6f3',
          'bg-hover': '#f1f0ed',
          text: '#37352f',
          'text-secondary': '#73716c',
          'text-tertiary': '#9b9a97',
          border: '#e9e9e7',
          'border-hover': '#d3d1cb',
        },
        // Dark mode colors
        'notion-dark': {
          bg: '#191919',
          'bg-secondary': '#252525',
          'bg-hover': '#2f2f2f',
          text: '#e3e2e0',
          'text-secondary': '#9b9a97',
          'text-tertiary': '#73716c',
          border: '#373737',
          'border-hover': '#4a4a4a',
        },
        // Accent colors (work in both modes)
        accent: {
          blue: '#2383e2',
          'blue-hover': '#1a6fc1',
          green: '#0f7b6c',
          'green-hover': '#0c6356',
          red: '#e03e3e',
          'red-hover': '#c13232',
          orange: '#d9730d',
          'orange-hover': '#b75f0a',
          purple: '#9065b0',
          'purple-hover': '#7952a3',
        }
      },

      // Typography (Notion uses system fonts)
      fontFamily: {
        sans: [
          '-apple-system',
          'BlinkMacSystemFont',
          '"Segoe UI"',
          'Helvetica',
          '"Apple Color Emoji"',
          'Arial',
          'sans-serif',
          '"Segoe UI Emoji"',
          '"Segoe UI Symbol"'
        ],
        mono: [
          'ui-monospace',
          'SFMono-Regular',
          '"SF Mono"',
          'Menlo',
          'Consolas',
          '"Liberation Mono"',
          'monospace'
        ]
      },

      // Spacing adjustments
      spacing: {
        '18': '4.5rem',
        '88': '22rem',
        '92': '23rem',
        '100': '25rem',
        '104': '26rem',
        '108': '27rem',
      },

      // Border radius (Notion uses subtle rounded corners)
      borderRadius: {
        'notion': '3px',
        'notion-lg': '8px',
      },

      // Box shadows (Notion's subtle shadows)
      boxShadow: {
        'notion': '0 1px 2px rgba(0, 0, 0, 0.04)',
        'notion-md': '0 2px 4px rgba(0, 0, 0, 0.08)',
        'notion-lg': '0 4px 8px rgba(0, 0, 0, 0.12)',
        'notion-xl': '0 8px 16px rgba(0, 0, 0, 0.16)',
        'notion-dark': '0 1px 2px rgba(0, 0, 0, 0.32)',
        'notion-dark-md': '0 2px 4px rgba(0, 0, 0, 0.48)',
        'notion-dark-lg': '0 4px 8px rgba(0, 0, 0, 0.64)',
      },

      // Transitions
      transitionDuration: {
        '250': '250ms',
      },

      // Z-index scale
      zIndex: {
        '100': '100',
        '200': '200',
        '300': '300',
      }
    },
  },

  plugins: [
    require('@tailwindcss/forms'),
  ],
}
