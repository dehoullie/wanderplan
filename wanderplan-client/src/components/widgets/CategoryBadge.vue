<template>
  <span class="category-badge d-inline-flex align-items-center gap-1">
    <component :is="icon" class="me-1" v-if="icon" style="width: 18px; height: 18px;" />
    <span>{{ label }}</span>
  </span>
</template>

<script setup>
import {
  Amphora,         // Museum
  Landmark,        // Historical Places
  Utensils,        // Restaurants
  Bird,            // Religious Site
  FerrisWheel,     // Theme Park
  ShoppingBag,     // Shopping and Commercial Areas
  MountainSnow,    // Natural points of interest
} from 'lucide-vue-next'

const props = defineProps({
  categorySlug: { type: String, required: true }
})

// Map slugs to icons and labels
const CATEGORIES = {
  museum:          { label: 'Museum', icon: Amphora },
  restaurants:     { label: 'Restaurants', icon: Utensils },
  historical_places: { label: 'Historical Places', icon: Landmark },
  historicalplaces: { label: 'Historical Places', icon: Landmark }, // fallback
  religious_site:  { label: 'Religious Site', icon: Bird },
  theme_park:      { label: 'Theme Park', icon: FerrisWheel },
  shopping_and_commercial_areas: { label: 'Shopping', icon: ShoppingBag },
  natural_points_of_interest: { label: 'Nature', icon: MountainSnow }
}

// Normalize slug (case, spaces, dashes, etc)
function normalizeSlug(slug) {
  if (!slug) return ''
  return slug.toLowerCase().replace(/[\s\-]/g, '_')
}

const normalizedSlug = normalizeSlug(props.categorySlug)
const category = CATEGORIES[normalizedSlug] || {
  label: props.categorySlug.replace(/_/g, ' '),
  icon: null
}

const icon = category.icon
const label = category.label
</script>

<style scoped>
.category-badge {
  font-size: 1em;
  font-weight: 500;
}
</style>
