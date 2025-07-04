<template>
  <section class="gallery-section">
    <div class="container">
    <h2>Not Sure Where to Go?</h2>
    <p class="subtitle">
      <b>Discover Popular Itineraries</b><br>
      Browse our most popular travel plans chosen by fellow travelers...
    </p>
    <div class="row">
      <div
        v-for="itinerary in itineraries"
        :key="itinerary.id"
        class="col-lg-3 col-sm-6 py-2"
        @click="goToItinerary(itinerary.id)"
      >
      <div class="gallery-card">
        <img
            :src="`/${itinerary.image_url || 'city_images/placeholder.jpg'}`"
            alt="city image"
            class="gallery-image"
          />
        <div class="gallery-main p-2">
          <span class="gallery-city">
            <span class="px-2"><CountryFlagByName :countryName="itinerary.country" /></span>
            <b>{{ itinerary.city }}, {{ itinerary.country }}</b>
          </span>
          <span class="gallery-days">
            {{ itinerary.days }} day<span v-if="itinerary.days > 1">s</span>
          </span>
        </div>
        <div class="gallery-pref p-2">
          {{ Array.isArray(itinerary.preferences) ? itinerary.preferences.join(', ') : itinerary.preferences }}
        </div>
        </div>
      </div>
    </div>
  </div>
  </section>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import CountryFlagByName from '@/components/widgets/CountryFlagByName.vue'

const itineraries = ref([])
const router = useRouter()

const fetchItineraries = async () => {
  const res = await fetch('/api/v1/itineraries/gallery')
  itineraries.value = await res.json()
}

onMounted(fetchItineraries)

function goToItinerary(id) {
  router.push(`/itinerary/${id}`)
}
</script>

<style scoped>
.gallery-section {
  margin: 48px 0;
}
.subtitle {
  margin-bottom: 24px;
}
.gallery-cards {
  display: flex;
  flex-wrap: wrap;
}
.gallery-card {
  background: #fff;
  border-radius: 4px;
  box-shadow: 0 2px 12px #0001;
  overflow: hidden;
  cursor: pointer;
  transition: transform 0.12s;
  display: flex;
  flex-direction: column;
  height: 100%;
}
.gallery-card:hover {
  transform: translateY(-5px) scale(1.01);
}
.gallery-image {
  width: 100%;
  aspect-ratio: 3/2;
  object-fit: cover;
}
.gallery-info {
  padding: 16px 20px 14px;
}
.gallery-main {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 6px;
}
.gallery-city {
  font-size: 1.08em;
}
.gallery-days {
  color: #555;
}
.gallery-pref {
  color: #444;
  font-size: 0.97em;
  margin-bottom: 6px;
}
.gallery-budget {
  font-size: 0.95em;
  color: #999;
}
@media (max-width: 900px) {
  .gallery-cards {
    flex-direction: column;
    gap: 20px;
    align-items: center;
  }
  .gallery-card {
    width: 95vw;
    max-width: 420px;
  }
}
</style>
