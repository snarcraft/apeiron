<script setup lang="ts">
// The gradient monogram — same shape as assets/icon.svg, recolored
// by the generated palette tokens.
</script>

<template>
  <span class="inline-flex items-center gap-2.5">
    <svg viewBox="0 0 64 64" class="size-7" aria-hidden="true">
      <defs>
        <linearGradient id="web-mark" x1="0" y1="0" x2="64" y2="64" gradientUnits="userSpaceOnUse">
          <stop offset="0" stop-color="var(--color-primary-500)" />
          <stop offset="1" stop-color="var(--color-secondary-500)" />
        </linearGradient>
      </defs>
      <rect width="64" height="64" rx="14" fill="url(#web-mark)" />
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
    <span class="text-highlighted font-semibold">{{APP_TITLE}}</span>
  </span>
</template>
