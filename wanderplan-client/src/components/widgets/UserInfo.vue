<template>
  <span style="text-align: center;" v-if="displayValue">
    {{ displayValue }}
  </span>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'

const props = defineProps({
  info: { type: String, required: true }
})

const user = ref(null)

onMounted(async () => {
  const token = localStorage.getItem('jwt') || sessionStorage.getItem('jwt')
  try {
    const response = await fetch('/api/v1/me', {
      headers: {
        'Content-Type': 'application/json',
        ...(token ? { 'Authorization': token } : {})
      }
    })
    if (response.ok) {
      user.value = await response.json()
    } else {
      user.value = null
    }
  } catch (e) {
    user.value = null
  }
})

// Compute the value to display
const displayValue = computed(() => {
  if (!user.value || !props.info) return ''
  if (props.info === 'initials' && user.value.name) {
    return user.value.name
      .split(' ')
      .map(part => part[0])
      .join('')
      .toUpperCase()
  }
  return user.value[props.info] || ''
})
</script>
