<template>
  <form @submit.prevent="onSubmit">
    <!-- Trip Name -->
    <div v-if="showTripName" class="mb-3">
      <label for="tripName" class="form-label">What's your next trip?</label>
      <input
        id="tripName"
        v-model="form.tripName"
        type="text"
        class="form-control"
        placeholder="Trip Name"
        :required="showTripName"
      />
    </div>

    <!-- Destination with autocomplete inside input-like container -->
    <div class="mb-3 position-relative">
      <label for="destination-input" class="form-label">Destination</label>
      <div class="form-control d-flex flex-wrap align-items-center gap-2">
        <!-- Capsules inside the same input box -->
        <span
          v-for="(city, idx) in form.selectedCities"
          :key="city.id"
          class="city-capsule d-flex align-items-center"
        >
           {{ city.city }}, {{ city.country }}
          <button
            type="button"
            class="btn-close btn-close-white btn-sm ms-2"
            @click="removeCity(idx)"
            aria-label="Remove"
          ></button>
        </span>
        <!-- Actual text input -->
        <input
          id="destination-input"
          v-model="destinationQuery"
          :placeholder="destinationPlaceholder"
          :disabled="!allowMultipleCities && form.selectedCities.length > 0"
          type="text"
          class="border-0 flex-fill"
          autocomplete="off"
        />
      </div>
      <!-- Suggestions dropdown -->
      <ul
        v-if="suggestions.length"
        class="list-group position-absolute w-100 shadow"
        style="z-index:1000; top: calc(100% + 0.25rem);"
      >
      <li
        v-for="s in suggestions"
        :key="s.id"
        class="list-group-item list-group-item-action"
        @click="selectCity(s)"
      >
        {{ s.label }}
      </li>
      </ul>
    </div>

    <!-- Preferences -->
    <div class="mb-3">
      <label class="form-label">Preferences</label><br />
      <div class="d-flex flex-wrap gap-2">
        <button
          v-for="cat in categories"
          :key="cat.name"
          type="button"
          class="btn btn-outline-secondary btn-sm d-flex align-items-center"
          :class="form.preferences.includes(cat.name) ? 'btn-orange text-white' : ''"
          @click="toggleCategory(cat.name)"
        >
          <component :is="cat.icon" class="me-1" />{{ cat.label }}
        </button>
      </div>
    </div>

    <!-- Budget -->
    <div class="mb-3">
      <label class="form-label">Budget</label><br />
      <div class="btn-group" role="group">
        <button
          v-for="level in budgetLevels"
          :key="level.id"
          type="button"
          class="btn btn-sm"
          :class="form.budget === level.id ? 'btn-orange' : 'btn-light'"
          @click="form.budget = level.id"
        >
          <component :is="level.icon" class="me-2" />{{ level.name }}
        </button>
      </div>
    </div>

    <!-- Dates: v-date-picker range with custom slots -->
    <div class="mb-3">
      <div class="mb-3">
        <label class="form-label">Select Range</label>
        <Datepicker
          v-model="form.dateRange"
          :range="{ maxRange: 4 }"
          :enable-time-picker="false"
          format="dd/MM/yyyy"
          placeholder="Select up to 7 days"
          :required="true"
          @range-limit-exceeded="onRangeLimitExceeded"
          @cleared="form.dateRange = null"
        />

      </div>
    </div>

    <!-- Call your friends -->
    <div v-if="showCallFriends" class="mb-3">
      <label for="friendEmail" class="form-label">Call your friends</label>
      <input
        id="friendEmail"
        v-model="form.friendEmail"
        type="email"
        class="form-control"
        placeholder="email@friend.com"
        :required="showCallFriends"
      />

    </div>

    <!-- Submit -->
    <div class="d-grid">
      <button
        type="submit"
        class="btn btn-orange"
        :disabled="!form.dateRange || !form.dateRange[0] || !form.dateRange[1]"
      >
        Let's travel
      </button>
    </div>
  </form>
  <div v-if="loading" class="position-fixed top-0 start-0 w-100 h-100 d-flex align-items-center justify-content-center" style="background:rgba(255,255,255,0.85);z-index:2000;">
  <div class="spinner-border text-orange" role="status" style="width:4rem;height:4rem;">
    <span class="visually-hidden">Loading...</span>
  </div>
</div>
</template>

<script setup>
import { reactive, ref, watch, computed } from 'vue'
import axios from 'axios'
import { format } from 'date-fns'
import {
  Amphora, Landmark, Utensils, Bird,
  FerrisWheel, ShoppingBag, MountainSnow,
  DollarSign, CreditCard, Star, Award,
  Calendar
} from 'lucide-vue-next'

import Datepicker from '@vuepic/vue-datepicker'
import '@vuepic/vue-datepicker/dist/main.css'

const dateRange = ref(null)
const dateRangeError = ref('')

function onRangeLimitExceeded() {
  dateRangeError.value = 'You can select up to 7 days only.'
  setTimeout(() => { dateRangeError.value = '' }, 2500)
}

const props = defineProps({
  showTripName:        { type: Boolean, default: true },
  showCallFriends:     { type: Boolean, default: true },
  allowMultipleCities: { type: Boolean, default: true }
})
const emit = defineEmits(['submit'])

const { allowMultipleCities } = props

// Autocomplete state
const destinationQuery = ref('')
const suggestions = ref([])

// Reactive form state
const form = reactive({
  tripName:        '',
  selectedCities:  [],
  preferences:     [],
  budget:          1, // default to "Low Budget"
  dateRange:       null,
  friendEmail:     ''
})

// Dynamic placeholder based on mode and selection
const destinationPlaceholder = computed(() => {
  if (allowMultipleCities) {
    return form.selectedCities.length > 0
      ? 'add another city'
      : 'Type a city name'
  } else {
    return form.selectedCities.length > 0
      ? 'Change city'
      : 'Type a city name'
  }
})

// Fetch city suggestions
watch(destinationQuery, async (newVal) => {
  console.log('[TripForm] destinationQuery changed:', newVal)
  if (newVal.length < 2) {
    suggestions.value = []
    return
  }
  try {
    const { data } = await axios.get('/api/v1/places', { params: { q: newVal } })
    console.log('[TripForm] places API returned:', data)
    suggestions.value = Array.isArray(data) ? data : []
  } catch (err) {
    console.error('[TripForm] places API error:', err)
    suggestions.value = []
  }
})

// Manage city selection
function selectCity(place) {
  if (!allowMultipleCities) {
    form.selectedCities.splice(0)
  }
  // Avoid duplicates
  if (!form.selectedCities.find(c => c.id === place.id)) {
    form.selectedCities.push({
      id: place.id,
      city: place.city,
      country: place.country
    })
  }
  destinationQuery.value = ''
  suggestions.value = []
}
function removeCity(idx) {
  form.selectedCities.splice(idx, 1)
}

// Preferences and budget options
const categories = [
  { name: 'Museum', label: 'Museum', icon: Amphora },
  { name: 'Historical Places', label: 'Historical Places', icon: Landmark },
  { name: 'Restaurants', label: 'Restaurants', icon: Utensils },
  { name: 'Religious Site', label: 'Religious Site', icon: Bird },
  { name: 'Theme Park', label: 'Theme Park', icon: FerrisWheel },
  { name: 'Shopping and Commercial Areas', label: 'Shopping & Commercial', icon: ShoppingBag },
  { name: 'Natural points of interest', label: 'Natural points of interest', icon: MountainSnow }
]
const budgetLevels = [
  { id: 1, name: 'Low Budget', icon: DollarSign },
  { id: 2, name: 'Medium Budget', icon: CreditCard },
  { id: 3, name: 'High Budget', icon: Star },
  { id: 4, name: 'Ultra-High Budget', icon: Award }
]
function toggleCategory(cat) {
  const idx = form.preferences.indexOf(cat)
  if (idx === -1) form.preferences.push(cat)
  else form.preferences.splice(idx, 1)
}

function extractJsonString(gptResponse) {
  if (!gptResponse) return null;

  // Remove triple backticks and optional 'json' after backticks (case insensitive)
  let cleaned = gptResponse.trim()
    .replace(/^```(?:json)?/i, '')
    .replace(/```$/, '');

  return cleaned.trim();
}
// CHeck if there is any same Itinerary
async function findExistingItinerary(city, preferences, budget, maxDays) {
  try {
    const response = await axios.get('/api/v1/itineraries/find_existing', {
      params: {
        city,
        preferences: preferences.join(','),
        budget,
        max_days: maxDays
      }
    });
    if (response.data && response.data.id) {
      return response.data.id;
    }
    return null;
  } catch (error) {
    // Ignore error, just return null
    return null;
  }
}

// Submit handler
import { useRouter } from 'vue-router'
const router = useRouter();

  async function onSubmit() {
    loading.value = true;

    // Compute all needed params
    const city = form.selectedCities[0]?.city || '';
    const preferences = form.preferences;
    const budget = form.budget;
    const start = form.dateRange ? form.dateRange[0] : null;
    const end = form.dateRange ? form.dateRange[1] : null;

    // Calculate max_days
    let maxDays = 1;
    if (start && end) {
      const d1 = new Date(start);
      const d2 = new Date(end);
      maxDays = Math.max(1, Math.round((d2 - d1) / (1000*60*60*24)) + 1);
    }

    // 1. Check for existing itinerary
    const existingId = await findExistingItinerary(city, preferences, budget, maxDays);
    if (existingId) {
      loading.value = false;
      router.push(`/itinerary/${existingId}`);
      return;
    }

    // 2. Otherwise, proceed to POST/plan and go to itinerary/:id
    try {
      const response = await axios.post('/api/v1/trips/plan', {
        trip_name: form.tripName,
        cities: form.selectedCities,
        preferences: preferences,
        budget: budget,
        start_date: start,
        end_date: end,
        friend_email: form.friendEmail
      });

      // Optionally, parse/save itinerary response as before...

      // Get id from save_result (check your backend structure!)
      const newId = response.data.save_result?.itinerary_id;
      loading.value = false;

      if (newId) {
        router.push(`/itinerary/${newId}`);
      } else {
        // Handle missing id error
        alert("Itinerary was created, but ID is missing!");
      }
    } catch (error) {
      loading.value = false;
      alert("An error occurred. Please try again!");
    }
  }
const loading = ref(false)
</script>

<style scoped>
.list-group-item-action { cursor: pointer; }
.city-capsule {
  background: #fff;
  border: 2px solid #ddd;
  border-radius: 1.5rem;
  padding: 0.25rem 1rem;
  font-weight: 600;
  font-size: 1rem;
  color: #222;
  margin-bottom: 0.25rem;
  margin-right: 0.5rem;
  box-shadow: 0 1px 2px rgba(0,0,0,0.03);
}
.city-capsule .btn-close {
  filter: invert(0.5);
  opacity: 0.7;
}
.icon-input {
  height: 20px;
}
</style>
