{
  "files.eol": "\n",
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll": "explicit",
    "source.fixAll.eslint": "explicit"
  },
  "editor.insertSpaces": true,
  "editor.tabSize": 2,
  "files.associations": {
    "*.css": "tailwindcss"
  },
  "tailwindCSS.classAttributes": ["class", "className", "ngClass", "ui"],
  "tailwindCSS.experimental.classRegex": [
    ["\\bui:\\s*[\"'`]([^{\"'`}]*)[\"'`]", "([a-zA-Z0-9\\-:/.]+)"]
  ],
  "[php]": {
    "editor.defaultFormatter": "junstyle.php-cs-fixer"
  },
  "php-cs-fixer.executablePath": "${workspaceFolder}/.vscode/php-cs-fixer.sh",
  "php-cs-fixer.config": "${workspaceFolder}/apps/backend/.php-cs-fixer.php",
  "php-cs-fixer.onsave": true,
  "files.watcherExclude": {
    "**/vendor/**": true,
    "**/.nuxt/**": true,
    "**/.output/**": true
  },
  "cSpell.words": ["{{APP_NAME}}", "octane", "reverb", "pennant", "promtail", "oklch"]
}
