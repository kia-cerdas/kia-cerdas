/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#185FA5',
          50:  '#EBF2FA',
          100: '#D0E2F4',
          200: '#A1C5E9',
          300: '#72A8DE',
          400: '#438BD3',
          500: '#185FA5',
          600: '#145190',
          700: '#10437A',
          800: '#0C3564',
          900: '#08274E',
        },
      },
      keyframes: {
        grow: {
          '0%': { width: '0%' },
          '100%': { width: '100%' },
        },
      },
      animation: {
        grow: 'grow 4s linear',
      },
    },
  },
  plugins: [],
}