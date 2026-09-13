<template>
  <div class="container mx-auto px-4 py-8">
    <!-- Breadcrumb -->
    <nav class="text-sm text-gray-500 mb-6 flex items-center gap-2">
      <router-link to="/" class="hover:text-orange-500">Home</router-link>
      <span>/</span>
      <span class="text-gray-700">Vouchers</span>
    </nav>

    <div class="mb-8">
      <h1 class="font-display text-2xl md:text-3xl font-bold text-gray-900 mb-2">
        Available Vouchers & Deals
      </h1>
      <p class="text-gray-500 text-sm">
        Copy a discount voucher code and apply it during checkout to save instantly on your orders.
      </p>
    </div>

    <div v-if="loading" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div v-for="n in 6" :key="n" class="skeleton rounded-2xl h-36"></div>
    </div>

    <div
      v-else-if="vouchers.length === 0"
      class="bg-white rounded-2xl shadow-sm border border-gray-100 p-12 text-center text-gray-400 max-w-xl mx-auto"
    >
      <div class="w-16 h-16 bg-orange-50 text-orange-500 rounded-full flex items-center justify-center mx-auto mb-4">
        🎟️
      </div>
      <p class="font-semibold text-gray-800 text-base mb-1">No vouchers available right now</p>
      <p class="text-sm text-gray-500">Check back soon for new seasonal discounts and promo events!</p>
    </div>

    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div
        v-for="voucher in vouchers"
        :key="voucher.code"
        class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 flex flex-col justify-between relative overflow-hidden transition hover:shadow-md hover:border-orange-200 group"
      >
        <!-- Top accent decoration -->
        <div class="absolute top-0 left-0 right-0 h-1.5 gradient-primary"></div>

        <div>
          <div class="flex items-start justify-between gap-3 mb-3">
            <div>
              <span class="inline-block px-3 py-1 bg-orange-100 text-orange-700 text-xs font-bold rounded-full mb-2">
                {{ voucherSummary(voucher) }}
              </span>
              <p class="font-mono font-bold text-xl text-gray-900 tracking-wider">
                {{ voucher.code }}
              </p>
            </div>

            <button
              class="shrink-0 text-xs font-semibold px-3.5 py-1.5 rounded-xl border border-orange-500 text-orange-600 hover:bg-orange-50 transition"
              @click="copyCode(voucher.code)"
            >
              {{ copiedCode === voucher.code ? "Copied! ✓" : "Copy code" }}
            </button>
          </div>

          <p v-if="voucher.description" class="text-sm text-gray-600 mb-3 leading-relaxed">
            {{ voucher.description }}
          </p>
        </div>

        <div class="pt-3 border-t border-dashed border-gray-200 text-xs text-gray-400 space-y-1">
          <p v-if="voucher.min_spend">
            Min spend: <strong class="text-gray-600">৳{{ Number(voucher.min_spend).toLocaleString() }}</strong>
          </p>
          <p v-if="voucher.per_customer_limit">
            Usage limit: <span class="text-gray-600">Once per customer</span>
          </p>
          <p v-if="voucher.expires_at">
            Valid until: <span class="text-gray-600">{{ formatDate(voucher.expires_at) }}</span>
          </p>
          <p v-else>
            Expiry: <span class="text-green-600 font-medium">No expiration</span>
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { getPublicVouchers, voucherSummary, type PublicVoucher } from "../services/vouchers";
import { useToastStore } from "../stores/toast";

const toast = useToastStore();

const vouchers = ref<PublicVoucher[]>([]);
const loading = ref(true);
const copiedCode = ref("");

onMounted(async () => {
  try {
    vouchers.value = await getPublicVouchers();
  } catch {
    toast.error("Failed to load vouchers.");
  } finally {
    loading.value = false;
  }
});

function formatDate(iso: string) {
  return new Date(iso).toLocaleDateString(undefined, {
    month: "long",
    day: "numeric",
    year: "numeric",
  });
}

async function copyCode(code: string) {
  try {
    await navigator.clipboard.writeText(code);
    copiedCode.value = code;
    setTimeout(() => (copiedCode.value = ""), 2000);
  } catch {
    toast.info(`Voucher code: ${code}`);
  }
}
</script>
