const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  darkMode: 'class',
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
      colors: {
        sand: '#F7F2EC',
        clay: '#E5D5C1',
        coral: '#FF6B5A',
        amber: '#FFB347',
        teal: '#2AB7A9',
        charcoal: '#2E2E2E',
        warmgray: '#8B8682',
        charcoalbg: '#1A1A1A',
        warmblack: '#121010',
      },
      fontSize: {
        h1: ['28px', { lineHeight: '1.2', fontWeight: '700' }],
        h2: ['22px', { lineHeight: '1.3', fontWeight: '600' }],
        body: ['16px', { lineHeight: '1.6', fontWeight: '400' }],
        caption: ['13px', { lineHeight: '1.4', fontWeight: '400' }],
      },
      transitionTimingFunction: {
        'brand': 'cubic-bezier(0.4, 0, 0.2, 1)'
      },
      transitionDuration: {
        brand: '350ms'
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ]
}
