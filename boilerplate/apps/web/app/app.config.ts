export default defineAppConfig({
  ui: {
    button: {
      slots: { base: 'justify-center' },
      variants: {
        block: {
          true: { base: 'w-full justify-center', trailingIcon: 'ms-0' }
        }
      }
    },
    colors: { primary: 'primary', secondary: 'secondary' }
  }
})
