<!-- layouts/DefaultLayout.vue -->
<template>
  <Header />
  <main>
    <slot />
  </main>
  <Footer />
</template>

<script setup>
import Header from '@/components/chrome/Header.vue'
import Footer from '@/components/chrome/Footer.vue'
</script>
