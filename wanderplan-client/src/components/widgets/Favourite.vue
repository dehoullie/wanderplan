<template>
  <button @click="toggleFavourite" :aria-pressed="isFavourited" class="favourite-btn">
    <svg v-if="isFavourited" xmlns="http://www.w3.org/2000/svg" width="28" height="28" fill="#e74c3c" viewBox="0 0 24 24">
      <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41 0.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
    </svg>
    <svg v-else xmlns="http://www.w3.org/2000/svg" width="28" height="28" fill="none" stroke="#e74c3c" stroke-width="2" viewBox="0 0 24 24">
      <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41 0.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
    </svg>
  </button>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'

const props = defineProps({
  itineraryId: { type: Number, required: true }
})

const isFavourited = ref(false)

onMounted(async () => {
  // Optionally, fetch if this itinerary is already favourited by the user
  try {
    const { data } = await axios.get(`/api/v1/itineraries/${props.itineraryId}/favourite`)
    isFavourited.value = data.favourited
  } catch (e) {
    isFavourited.value = false
  }
})

async function toggleFavourite() {
  try {
    if (isFavourited.value) {
      await axios.delete(`/api/v1/itineraries/${props.itineraryId}/favourite`)
      isFavourited.value = false
    } else {
      await axios.post(`/api/v1/itineraries/${props.itineraryId}/favourite`)
      isFavourited.value = true
    }
  } catch (e) {
    // Optionally handle error
  }
}
</script>

<style scoped>
.favourite-btn {
  background: none;
  border: none;
  cursor: pointer;
  padding: 0;
  outline: none;
  display: flex;
  align-items: center;
}
</style>
