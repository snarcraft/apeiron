{
  "$schema": "https://opencode.ai/config.json",
  "lsp": {
    "typescript": {
      "command": "typescript-language-server",
      "args": ["--stdio"],
      "languages": ["typescript", "javascript"]
    },
    "vue": {
      "command": "vue-language-server",
      "args": ["--stdio"],
      "languages": ["vue"]
    },
    "intelephense": {
      "command": "intelephense",
      "args": ["--stdio"],
      "languages": ["php"]
    },
    "laravel": {
      "command": "laravel-lsp",
      "languages": ["php", "blade"]
    }
  },
  "mcp": {
    "laravel-boost": {
      "type": "local",
      "command": ["php", "apps/backend/artisan", "boost:mcp"],
      "enabled": true
    },
    "nuxt": {
      "type": "remote",
      "url": "https://nuxt.com/mcp",
      "enabled": true
    },
    "nuxt-ui": {
      "type": "remote",
      "url": "https://ui.nuxt.com/mcp",
      "enabled": true
    }
  }
}
