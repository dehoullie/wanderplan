<template>
  <DefaultLayout>
    <component :is="component" />
  </DefaultLayout>
</template>

<script setup>
import { defineProps } from 'vue'
import DefaultLayout from './DefaultLayout.vue'

const props = defineProps({
  component: {
    type: Object,
    required: true
  }
})
</script>
