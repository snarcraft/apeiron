<script setup lang="ts">
// The gradient monogram — identical to the website Logo mark.
</script>

<template>
  <svg viewBox="0 0 64 64" class="size-8" aria-hidden="true">
    <defs>
      <linearGradient id="app-mark" x1="0" y1="0" x2="64" y2="64" gradientUnits="userSpaceOnUse">
        <stop offset="0" stop-color="var(--color-primary-500)" />
        <stop offset="1" stop-color="var(--color-secondary-500)" />
      </linearGradient>
    </defs>
    <rect width="64" height="64" rx="14" fill="url(#app-mark)" />
    <text
      x="32"
      y="32"
      dy=".36em"
      text-anchor="middle"
      font-family="system-ui, sans-serif"
      font-size="34"
      font-weight="700"
      fill="#fff"
    >
      {{APP_LETTER}}
    </text>
  </svg>
</template>
