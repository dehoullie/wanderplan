<template>
  <div class="itinerary-page container">
    <!-- ITINERARY SUMMARY HEADER -->
    <div class="itinerary-summary">
      <div class="right-summary">
        <div class="summary-box">
          <img
            v-if="cityImageUrl"
            :src="`/${cityImageUrl}`"
            alt="City"
            class="summary-image"
          />
          <div class="summary-details" v-if="itineraryData">
            <div>
              <strong>{{ cityName }}, {{ countryName }}</strong>
              <span style="margin-left: 16px;">{{ numDays }} days</span>
            </div>
            <div class="summary-tags">
              <span v-for="cat in summaryCategories" :key="cat" class="badge">{{ cat }}</span>
            </div>
            <div>
              <span>{{ budgetLabel }}</span>
            </div>
          </div>
        </div>
      </div>
      <div class="left-summary">
        <h1>Your Personalized Itinerary is Ready!</h1>
        <p class="summary-subtitle"><strong>Check out your detailed itinerary</strong><br>
          Below, you'll find your daily schedule, meticulously tailored based on your preferences and budget.<br>
          Each day is planned to maximize your experience, including visits to landmarks, recommended restaurants, and special activities.
        </p>
      </div>
    </div>

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
                  <span class="badge d-block mt-1" :class="'cat-' + (activity.category_slug || 'other')">
                    {{ activity.category_name }}
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
.summary-image { width: 100%; max-width: 300px; border-radius: 8px; margin-bottom: 0.75rem; }
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
.cat-Museum { background: #dbeafe; color: #155e75; }
.cat-Restaurants { background: #fee2e2; color: #b91c1c; }
.cat-Historical_Places, .cat-HistoricalPlaces { background: #fef3c7; color: #b45309; }
.cat-Religious_Site { background: #ede9fe; color: #6d28d9; }
.cat-Shopping_and_Commercial_Areas { background: #f3f4f6; color: #0d9488; }
.cat-Natural_points_of_interest { background: #dcfce7; color: #166534; }
.cat-Theme_Park { background: #fce7f3; color: #a21caf; }
</style>
