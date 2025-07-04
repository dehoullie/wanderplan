<script setup>
import CountryFlag from 'vue-country-flag-next'
import { getCode } from 'country-list'

const props = defineProps({
  countryName: String,
  size: {
    type: String,
    default: 'normal'
  }
})

const countryNameMapping = {
  USA: "USA",
  US: "USA",
  "United States": "USA",
  "United States of America": "USA",
  UK: "United Kingdom",
  England: "United Kingdom",
  Scotland: "United Kingdom",
  Wales: "United Kingdom",
  "Northern Ireland": "United Kingdom",
  Russia: "Russian Federation",
  "South Korea": "Korea, Republic of",
  "North Korea": "Korea, Democratic People's Republic of",
  Iran: "Iran, Islamic Republic of",
  Syria: "Syrian Arab Republic",
  "Czech Republic": "Czechia",
  "Ivory Coast": "Côte d'Ivoire",
  Tanzania: "Tanzania, United Republic of",
  Venezuela: "Venezuela, Bolivarian Republic of",
  Vietnam: "Viet Nam",
  Moldova: "Moldova, Republic of",
  Bolivia: "Bolivia, Plurinational State of",
  Laos: "Lao People's Democratic Republic",
  Macau: "Macao",
  Myanmar: "Myanmar",
  Brunei: "Brunei Darussalam",
  "Cape Verde": "Cabo Verde",
  Palestine: "Palestine, State of",
  Congo: "Congo",
  "DR Congo": "Congo, Democratic Republic of the",
  "Saint Kitts": "Saint Kitts and Nevis",
  "Saint Lucia": "Saint Lucia",
  "St. Vincent": "Saint Vincent and the Grenadines",
  "Timor-Leste": "Timor-Leste",
  Taiwan: "Taiwan, Province of China",
  "Hong Kong": "Hong Kong",
  Curaçao: "Curaçao",
  Micronesia: "Micronesia, Federated States of"
}

// Canonicalize country name
const canonicalCountryName = countryNameMapping[props.countryName] || props.countryName

// --- FOR USA: always use 'usa' as code ---
let code = ''
if (
  canonicalCountryName === 'USA' ||
  props.countryName === 'USA' ||
  props.countryName === 'US' ||
  props.countryName === 'United States' ||
  props.countryName === 'United States of America'
) {
  code = 'usa'
} else if (
  canonicalCountryName === 'United Kingdom' ||
  props.countryName === 'UK' ||
  props.countryName === 'England' ||
  props.countryName === 'Scotland' ||
  props.countryName === 'Wales' ||
  props.countryName === 'Northern Ireland'
) {
  code = 'gb'
} else {
  code = getCode(canonicalCountryName) || ''
}

// console.log('Country input:', props.countryName, '| canonical:', canonicalCountryName, '| code:', code)
</script>

<template>
  <span class="country-flag">
    <CountryFlag v-if="code" :country="code.toLowerCase()" :size="props.size" />
    <span v-else>🏳️</span>
  </span>
</template>
