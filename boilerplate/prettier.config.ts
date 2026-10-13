export default {
  useTabs: false,
  proseWrap: 'always',
  tabWidth: 2,
  singleQuote: true,
  semi: false,
  trailingComma: 'none',
  endOfLine: 'lf',
  printWidth: 100,
  arrowParens: 'avoid',
  bracketSpacing: true,
  singleAttributePerLine: true,
  plugins: ['prettier-plugin-organize-imports', 'prettier-plugin-tailwindcss'],
  tailwindStylesheet: './apps/frontend/app/assets/css/main.css'
}
