<template>
  <section class="container-fluid py-5">
    <div class="container">
      <div class="row align-items-center">
        <!-- Text Column -->
        <div class="col-12 col-md-6 mb-4 mb-md-0">
          <h1 class="display-4 fw-bold">Welcome to Wanderplan</h1>
          <p class="lead text-secondary mb-4">Effortless travel planning is just a click away.</p>
        </div>
        <!-- Image Column -->
        <div class="col-12 col-md-6 text-center">
          <img src="@/assets/images/hero.png" alt="Hero banner" class="img-fluid" />
          <router-link to="/planning" class="btn btn-orange btn-lg mb-3 my-3">
            Start planning your trip now!
          </router-link>
          <p class="text-center text-muted">
            Create your personalised itinerary now and enjoy the perfect trip.
          </p>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
// no additional logic for now
</script>

<style scoped>
/* adjust spacing if needed */
</style>
