<template>
  <TopBanner v-if="!minimalChrome" />
  <Header
    :hide-search="minimalChrome"
    @open-cart="openCart"
    @open-track-order="openOrderTracking"
  />
  <OrderTrackingModal
    v-if="showOrderTrackingModal"
    @close-order-tracking="closeOrderTracking"
  />
  <router-view />
  <Footer @open-track-order="openOrderTracking" />
</template>

<script setup lang="ts">
import { computed, ref, watch } from "vue";
import { useRoute, useRouter } from "vue-router";

import TopBanner from "../components/common/TopBanner.vue";
import Header from "../components/common/Header.vue";
import OrderTrackingModal from "../components/common/OrderTrackingModal.vue";
import Footer from "../components/common/Footer.vue";
const route = useRoute();
const router = useRouter();

const minimalChrome = computed(() => route.meta.minimalChrome === true);

const showOrderTrackingModal = ref(false);

function openCart() {
  router.push("/cart");
}

watch(
  () => route.query.checkout,
  (flag) => {
    if (flag !== "1") return;
    const { checkout: _checkout, ...rest } = route.query;
    router.replace({ path: "/checkout", query: rest });
  },
  { immediate: true }
);

function openOrderTracking() {
  showOrderTrackingModal.value = true;
}

function closeOrderTracking() {
  showOrderTrackingModal.value = false;
}
</script>
