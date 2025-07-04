<template>
  <div class="itinerary-page container">
    <!-- ITINERARY SUMMARY HEADER -->
    <div class="row">
      <div class="col-sm-12 col-md-6">
        <div class="itinerary-image">
          <img
            v-if="cityImageUrl && !imageError"
            :src="`/${cityImageUrl}?${Date.now()}`"
            alt="City"
            class="summary-image"
            @load="handleImageLoad"
            @error="handleImageError"
          />
          <div v-if="imageLoading" class="placeholder-loader">
            <!-- Put a spinner/placeholder here -->
            Loading image...
          </div>
          <div v-if="imageError" class="placeholder-error">
            <!-- Put an error/placeholder image here -->
            Image not available yet. Retrying...
          </div>
        </div>
          <div class="summary-details py-2" v-if="itineraryData">
          <div class="d-flex justify-content-between">
            <strong>{{ cityName }}, {{ countryName }}</strong>
            <span style="margin-left: 16px;">{{ numDays }} days</span>
          </div>
          <div class="summary-tags">
            <span v-for="cat in summaryCategories" :key="cat" class="badge">{{ cat }}</span>
          </div>
          <div>
            <span><BudgetBadge :budget-level="itineraryData.preference.budget.name" /></span>
          </div>
        </div>
        </div>
        <div class="col-sm-12 col-md-6 m-auto">
          <h1>Your Personalized Itinerary is Ready!</h1>
          <p class="summary-subtitle"><strong>Check out your detailed itinerary</strong><br>
            Below, you'll find your daily schedule, meticulously tailored based on your preferences and budget.<br>
            Each day is planned to maximize your experience, including visits to landmarks, recommended restaurants, and special activities.
          </p>
        </div>
      </div>
<hr>

    <!-- DAILY ITINERARY SECTION -->
    <div class="itinerary-schedule" v-if="groupedActivities && groupedActivities.length">
      <div v-for="(day, idx) in groupedActivities" :key="day.day" class="day-section">
        <h2>Day {{ day.day }}</h2>
        <div class="day-parts">
          <div v-for="part in ['morning', 'afternoon', 'evening']" :key="part" class="part-section">
            <h4>{{ capitalize(part) }}</h4>
            <div class="activity-cards-row">
              <div
                v-for="activity in day[part]"
                :key="activity.id"
                class="activity-card"
              >
                <div class="card-header">
                  <strong>{{ activity.name }}</strong>
                  <span class="badge" :class="'cat-' + (activity.category_slug || 'other')">
                    <CategoryBadge :categorySlug="activity.category_slug" />
                  </span>
                </div>
                <div class="card-description">
                  <span>{{ activity.description }}</span>
                </div>
                <div class="card-address">
                  <strong>Address</strong><br>
                  <a
                    :href="`https://www.google.com/maps/place/${encodeURIComponent(activity.address)}`"
                    class="address-link"
                    target="_blank"
                    rel="noopener"
                  >
                    {{ activity.address }}
                  </a>
                </div>
              </div>
            </div>
          </div>
        </div>
        <hr v-if="idx !== groupedActivities.length - 1" />
      </div>
    </div>
    <div v-else>
      <p>Loading itinerary...</p>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRoute } from 'vue-router'
import axios from 'axios'
import CategoryBadge from '@/components/widgets/CategoryBadge.vue'
import BudgetBadge from '@/components/widgets/BudgetBadge.vue'

const route = useRoute()
const itineraryData = ref(null)
const groupedActivities = ref([])

const cityName = computed(() =>
  itineraryData.value?.preference?.city?.name || 'Unknown'
)
const countryName = computed(() =>
  itineraryData.value?.preference?.city?.country?.name || 'Unknown'
)
const numDays = computed(() =>
  itineraryData.value?.preference?.max_days || '?'
)
const summaryCategories = computed(() =>
  itineraryData.value?.summary_categories || []
)
const budgetLabel = computed(() =>
  itineraryData.value?.preference?.budget?.name || ''
)

// Helper
function capitalize(str) {
  if (!str) return ''
  return str.charAt(0).toUpperCase() + str.slice(1)
}

onMounted(async () => {
  const id = route.params.id
  // Expecting backend to send: itinerary, preference (with city, country, budget), activities, summary_categories, etc
  const response = await axios.get(`/api/v1/itineraries/${id}`)
  itineraryData.value = response.data

  // Group activities by day/part_of_day for table rendering
  if (response.data.activities) {
    // Gather all days
    const byDay = {}
    response.data.activities.forEach(act => {
      if (!byDay[act.day]) {
        byDay[act.day] = { day: act.day, morning: [], afternoon: [], evening: [] }
      }
      byDay[act.day][act.part_of_day]?.push(act)
    })
    // Sort by day
    groupedActivities.value = Object.values(byDay).sort((a, b) => a.day - b.day)
  }
})
// CHeck if city image URL exists
const cityImageUrl = computed(() =>
  itineraryData.value?.preference?.city?.image_url || null
)
const imageLoading = ref(true)
const imageError = ref(false)

function handleImageLoad() {
  imageLoading.value = false
  imageError.value = false
}
function handleImageError() {
  // If image fails, try again in 2 seconds, up to 5 attempts
  imageError.value = true
  imageLoading.value = false
  retryImage()
}

let retryCount = 0
function retryImage() {
  if (retryCount < 5) {
    retryCount++
    imageLoading.value = true
    setTimeout(() => {
      // This will cause the <img> tag to reload
      imageLoading.value = false
      imageError.value = false
    }, 1800)
  }
}
</script>

<style scoped>
.container { max-width: 1200px; margin: 0 auto; padding: 2rem 0; }
.itinerary-summary { display: flex; gap: 3rem; align-items: flex-start; margin-bottom: 3rem; }
.left-summary {
  flex: 2;
  margin: auto;
}
.right-summary {
  flex: 1;

}
.summary-box { background: #f6f6f6; padding: 1rem; border-radius: 8px; }
.itinerary-image {
  width: 100%;
  height: 300px;
  overflow: hidden;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
}
.summary-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  object-position: center center; /* Center both horizontally and vertically */
  display: block;
}

.summary-tags { margin: 0.75rem 0; }
.badge { background: #e4e4e7; color: #333; border-radius: 8px; padding: 0.2em 0.7em; margin-right: 0.5em; font-size: 0.95em; }
.day-section { margin-bottom: 2.5rem; }
.day-parts { display: flex; flex-direction: column; gap: 1.25rem; }
.part-section { margin-bottom: 1.25rem; }
.activity-cards-row {
  display: flex;
  flex-wrap: wrap;
  gap: 1.25rem;
  width: 100%;
}

.activity-card {
  background: #fff;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  padding: 1rem;
  flex: 1 1 calc(33.333% - 1.25rem); /* 3 per row, minus gap */
  min-width: 0;
  max-width: calc(33.333% - 1.25rem);
  min-height: 140px;
  box-sizing: border-box;
}

/* Responsive: stack cards and summary on small screens */
@media (max-width: 767px) {
  .itinerary-summary {
    flex-direction: column;
    gap: 1.5rem;
    margin-left: 0.5rem;
    margin-right: 0.5rem;
  }
  .left-summary,
  .right-summary {
    width: 100%;
    margin-left: 0;
    margin-right: 0;
  }
  .summary-box {
    margin-left: 0;
    margin-right: 0;
  }
  .activity-cards-row {
    flex-direction: column;
    gap: 1rem;
  }
  .activity-card {
    max-width: 100%;
    flex-basis: 100%;
    margin-left: 0.5rem;
    margin-right: 0.5rem;
  }
  h2 {
    margin-left: 0.5rem;
    margin-right: 0.5rem;
  }
  h4 {
    margin-left: 0.5rem;
    margin-right: 0.5rem;
  }
}

.card-header {
  display: flex;
  flex-direction: column;      /* stack vertically */
  align-items: flex-start;     /* align left */
  gap: 0.5em;
  margin-bottom: 0.5em;
}
.card-description { color: #444; margin-bottom: 0.6em; }
.card-address { color: #666; font-size: 0.92em; }
.cat-museum,
.category-badge.cat-museum { background: #e0ecff; color: #1769aa; }
.cat-historical_places,
.category-badge.cat-historical_places { background: #ffe9d5; color: #ad4d00; }
.cat-restaurants,
.category-badge.cat-restaurants { background: #ffe4e1; color: #e63946; }
.cat-religious_site,
.category-badge.cat-religious_site { background: #f4e5ff; color: #6b21a8; }
.cat-theme_park,
.category-badge.cat-theme_park { background: #fff0fa; color: #a21caf; }
.cat-shopping_and_commercial_areas,
.category-badge.cat-shopping_and_commercial_areas { background: #e9f5e1; color: #15803d; }
.cat-natural_points_of_interest,
.category-badge.cat-natural_points_of_interest { background: #e1fff5; color: #00796b; }
</style>
