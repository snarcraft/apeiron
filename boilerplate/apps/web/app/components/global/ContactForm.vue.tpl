<script setup lang="ts">
const { t } = useI18n()
const toast = useToast()
const loading = ref(false)

const state = reactive({ name: '', email: '', message: '' })

async function submit() {
  loading.value = true

  try {
    await $fetch('/api/contacts', { method: 'POST', body: state })

    toast.add({
      color: 'success',
      icon: 'i-lucide-check',
      title: t('contact.successTitle'),
      description: t('contact.successBody')
    })

    Object.assign(state, { name: '', email: '', message: '' })
  } catch (error: unknown) {
    const errors = (error as { data?: { errors?: Record<string, string[]> } })?.data?.errors

    toast.add({
      color: 'error',
      icon: 'i-lucide-alert-triangle',
      title: t('contact.errorTitle'),
      description: errors ? Object.values(errors).flat().join(' ') : t('contact.errorBody')
    })
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <UForm :state="state" class="mt-8 space-y-4" @submit="submit">
    <UFormField :label="t('contact.name')" name="name">
      <UInput
        v-model="state.name"
        :placeholder="t('contact.namePlaceholder')"
        icon="i-lucide-user"
        class="w-full"
        required
      />
    </UFormField>

    <UFormField :label="t('contact.email')" name="email">
      <UInput
        v-model="state.email"
        type="email"
        :placeholder="t('contact.emailPlaceholder')"
        icon="i-lucide-mail"
        class="w-full"
        required
      />
    </UFormField>

    <UFormField :label="t('contact.message')" name="message">
      <UTextarea
        v-model="state.message"
        :placeholder="t('contact.messagePlaceholder')"
        :rows="4"
        class="w-full"
        required
      />
    </UFormField>

    <UButton
      type="submit"
      block
      size="lg"
      :loading="loading"
      trailing-icon="i-lucide-send"
    >
      {{ t('contact.submit') }}
    </UButton>
  </UForm>
</template>
