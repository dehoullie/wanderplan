<template>
  <span class="budget-badge d-inline-flex align-items-center gap-1" :class="badgeClass">
    <component :is="icon" v-if="icon" class="me-1" style="width: 18px; height: 18px;" />
    <span>{{ label }}</span>
  </span>
</template>

<script setup>
import { DollarSign, CreditCard, Star, Award } from 'lucide-vue-next'

const props = defineProps({
  budgetLevel: {
    type: [String, Number],
    required: true
  }
})

// Accepts number or string
const BUDGETS = [
  { key: 1, name: 'Low Budget',      slug: 'low',    icon: DollarSign,   class: 'budget-low' },
  { key: 2, name: 'Medium Budget',   slug: 'medium', icon: CreditCard,   class: 'budget-medium' },
  { key: 3, name: 'High Budget',     slug: 'high',   icon: Star,         class: 'budget-high' },
  { key: 4, name: 'Ultra-High Budget', slug: 'ultra', icon: Award,       class: 'budget-ultra' }
]

function getBudgetData(level) {
  // Accept both name and numeric level
  if (!level) return BUDGETS[0]
  if (typeof level === 'number') return BUDGETS.find(b => b.key === level) || BUDGETS[0]
  // Match by name (case-insensitive) or slug
  const norm = level.toString().toLowerCase()
  return (
    BUDGETS.find(b => b.name.toLowerCase() === norm) ||
    BUDGETS.find(b => b.slug === norm) ||
    BUDGETS[0]
  )
}

const { icon, name: label, class: badgeClass } = getBudgetData(props.budgetLevel)
</script>

<style scoped>
.budget-badge {
  font-size: 1em;
  font-weight: 500;
  border-radius: 8px;
  padding: 0.2em 0.7em;
}
/* .budget-low    { background: #e0ffe0; color: #2d6a2d; }
.budget-medium { background: #e8f3ff; color: #1565c0; }
.budget-high   { background: #fff4e0; color: #b76f00; }
.budget-ultra  { background: #fde7ff; color: #930fa8; } */
</style>
