<script setup lang="ts">
definePageMeta({ layout: 'auth' })

const { t } = useI18n()
const { login } = useSanctumAuth()
const toast = useToast()

const state = reactive({ email: '', password: '', remember: false })
const loading = ref(false)

async function submit() {
  loading.value = true

  try {
    await login({ email: state.email, password: state.password })
  } catch {
    toast.add({
      color: 'error',
      icon: 'i-lucide-alert-triangle',
      title: t('pages.login.failedTitle'),
      description: t('pages.login.failedBody')
    })
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="soul-card w-full max-w-md p-8">
    <div class="flex items-center gap-3">
      <Mark />
      <div>
        <h1 class="text-lg font-semibold text-highlighted">{{ t('pages.login.title') }}</h1>
        <p class="text-sm text-muted">{{ t('pages.login.subtitle', { app: '{{APP_TITLE}}' }) }}</p>
      </div>
    </div>

    <UForm :state="state" class="mt-8 space-y-4" @submit="submit">
      <UFormField :label="t('pages.login.email')" name="email">
        <UInput
          v-model="state.email"
          type="email"
          icon="i-lucide-mail"
          :placeholder="t('pages.login.emailPlaceholder')"
          class="w-full"
          autofocus
          required
        />
      </UFormField>

      <UFormField :label="t('pages.login.password')" name="password">
        <UInput
          v-model="state.password"
          type="password"
          icon="i-lucide-lock"
          class="w-full"
          required
        />
      </UFormField>

      <UButton type="submit" block size="lg" :loading="loading" trailing-icon="i-lucide-arrow-right">
        {{ t('pages.login.submit') }}
      </UButton>
    </UForm>
  </div>
</template>
