<template>
  <div class="container py-5">
    <h2 class="mb-4">Plan Your Trip</h2>

    <!-- Example: single-city mode -->
    <TripForm
      :showTripName="false"
      :showCallFriends="false"
      :allowMultipleCities="false"
      @submit="handleSubmit"
    />

    <hr class="my-5" />
  </div>
</template>

<script setup>
import TripForm from '@/components/forms/TripForm.vue'

function handleSubmit(data) {
  console.log('Form submitted:', data)
  // handle CRUD/API call here
}
</script>

<style scoped>
/* page-specific styles */
</style>
