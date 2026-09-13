<template>
  <div class="container mx-auto px-4 py-8">
    <!-- Breadcrumb -->
    <nav class="text-sm text-gray-500 mb-6 flex items-center gap-2" aria-label="Breadcrumb">
      <router-link to="/" class="hover:text-orange-500 transition">Home</router-link>
      <span>/</span>
      <router-link to="/account" class="hover:text-orange-500 transition">My Account</router-link>
      <span>/</span>
      <span class="text-gray-800 font-medium">My Orders</span>
    </nav>

    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
      <div>
        <h1 class="font-display text-2xl md:text-3xl font-bold text-gray-900">
          Order History
        </h1>
        <p class="text-gray-500 text-sm mt-1">
          Review details of your past orders, track delivery status, or complete pending payments.
        </p>
      </div>

      <router-link
        to="/products"
        class="inline-flex items-center gap-2 text-sm font-semibold text-orange-600 hover:text-orange-700 transition"
      >
        <span>Explore Products →</span>
      </router-link>
    </div>

    <AccountNav />

    <!-- Loading State -->
    <div v-if="loading" class="bg-white rounded-2xl shadow-sm border border-gray-100 p-12 text-center text-gray-500 space-y-4">
      <div class="w-10 h-10 border-4 border-orange-500 border-t-transparent rounded-full animate-spin mx-auto"></div>
      <p class="text-sm font-medium">Loading your orders...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="bg-white rounded-2xl shadow-sm border border-red-100 p-12 text-center text-red-500">
      <p class="mb-3">{{ error }}</p>
      <button
        class="text-orange-500 font-medium hover:underline text-sm"
        @click="loadOrders(meta.current_page)"
      >
        Try again
      </button>
    </div>

    <!-- Empty State -->
    <div
      v-else-if="orders.length === 0"
      class="bg-white rounded-2xl shadow-sm border border-gray-100 p-12 md:p-16 text-center max-w-2xl mx-auto"
    >
      <div class="w-20 h-20 bg-orange-50 rounded-full flex items-center justify-center mx-auto mb-4 text-orange-500">
        <svg class="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
        </svg>
      </div>
      <h2 class="font-display text-xl font-bold text-gray-800 mb-2">No orders placed yet</h2>
      <p class="text-gray-500 text-sm max-w-sm mx-auto mb-6">
        When you place an order, its real-time shipping tracking, receipt, and details will appear here.
      </p>
      <router-link
        to="/products"
        class="inline-block gradient-primary text-white font-semibold px-8 py-3 rounded-xl shadow hover:opacity-95 transition text-sm"
      >
        Start Shopping Now
      </router-link>
    </div>

    <!-- Orders List -->
    <template v-else>
      <div class="space-y-5">
        <div
          v-for="order in orders"
          :key="order.id"
          class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5 sm:p-6 transition hover:shadow-md"
        >
          <!-- Order Header Bar -->
          <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-4 border-b border-gray-100">
            <div>
              <div class="flex items-center gap-2.5">
                <span class="font-mono font-bold text-gray-900 text-base sm:text-lg">
                  {{ order.order_number }}
                </span>
                <span class="text-xs text-gray-400">·</span>
                <span class="text-xs text-gray-500">
                  {{ new Date(order.created_at).toLocaleDateString(undefined, { year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' }) }}
                </span>
              </div>
            </div>

            <div class="flex items-center gap-2">
              <span
                class="px-3 py-1 rounded-full text-xs font-semibold"
                :class="order.payment_status === 'paid' ? 'bg-green-100 text-green-700' : 'bg-amber-100 text-amber-700'"
              >
                {{ order.payment_status === "paid" ? "✓ Paid" : `Unpaid · ${order.payment_method}` }}
              </span>
              <span
                class="px-3 py-1 rounded-full text-xs font-semibold capitalize"
                :class="statusClass(order.status)"
              >
                {{ order.status }}
              </span>
            </div>
          </div>

          <!-- Items list -->
          <div class="py-3 divide-y divide-gray-50">
            <div
              v-for="item in order.items"
              :key="item.id"
              class="py-3 flex flex-col sm:flex-row sm:items-center justify-between gap-2 text-sm"
            >
              <div class="flex items-center gap-3">
                <span class="w-7 h-7 rounded-lg bg-gray-100 text-gray-600 flex items-center justify-center text-xs font-bold shrink-0">
                  {{ item.quantity }}×
                </span>
                <div>
                  <span class="font-medium text-gray-800">{{ item.product_name }}</span>
                  <span v-if="item.variant_label" class="text-xs text-gray-400 ml-1.5">({{ item.variant_label }})</span>
                  <router-link
                    v-if="order.status === 'delivered' && item.product"
                    :to="`/products/${item.product.slug}?review=1`"
                    class="text-orange-500 text-xs font-semibold hover:underline ml-2"
                  >
                    ★ Write a review
                  </router-link>
                </div>
              </div>
              <span class="font-semibold text-gray-800 text-right">৳{{ item.subtotal.toLocaleString() }}</span>
            </div>
          </div>

          <!-- Summary footer -->
          <div class="pt-3 border-t border-gray-100 flex flex-col sm:flex-row sm:items-center justify-between gap-2">
            <div class="text-xs text-gray-500">
              Payment via <span class="font-medium text-gray-700">{{ order.payment_method }}</span>
            </div>

            <div class="text-right">
              <p v-if="Number(order.discount) > 0" class="text-xs text-green-600 font-medium">
                Voucher discount ({{ order.voucher_code }}): −৳{{ Number(order.discount).toLocaleString() }}
              </p>
              <p class="text-base font-bold text-gray-900">
                Total: <span class="text-orange-500">৳{{ Number(order.total).toLocaleString() }}</span>
              </p>
            </div>
          </div>

          <!-- Awaiting Card Payment Banner -->
          <div
            v-if="order.payment_method === 'Card' && order.payment_status === 'unpaid' && order.status === 'pending'"
            class="mt-4 p-3.5 bg-orange-50/70 border border-orange-200 rounded-xl flex items-center justify-between gap-3"
          >
            <p class="text-xs text-orange-800 font-medium">This order is awaiting card payment confirmation.</p>
            <button
              class="gradient-primary text-white px-4 py-2 rounded-xl text-xs font-semibold shadow hover:opacity-90 transition disabled:opacity-50 shrink-0"
              :disabled="payingOrderId === order.id"
              @click="payNow(order)"
            >
              {{ payingOrderId === order.id ? "Redirecting..." : "Pay Now via Stripe" }}
            </button>
          </div>
        </div>
      </div>

      <!-- Pagination -->
      <div class="mt-6 bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
        <Pagination
          :current-page="meta.current_page"
          :last-page="meta.last_page"
          :total="meta.total"
          :from="meta.from"
          :to="meta.to"
          @change="loadOrders"
        />
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from "vue";
import { getMyOrders } from "../../services/account";
import { payOrder, type Order } from "../../services/orders";
import { useToastStore } from "../../stores/toast";
import AccountNav from "../../components/account/AccountNav.vue";
import Pagination from "../../components/common/Pagination.vue";

const orders = ref<Order[]>([]);
const meta = ref({
  current_page: 1,
  last_page: 1,
  total: 0,
  from: null as number | null,
  to: null as number | null,
});
const loading = ref(true);
const error = ref("");
const payingOrderId = ref<number | null>(null);
const toast = useToastStore();

async function payNow(order: Order) {
  if (payingOrderId.value) return;
  payingOrderId.value = order.id;

  try {
    const { url } = await payOrder(order.id);
    window.location.href = url;
  } catch {
    toast.error("Could not start the payment. Please try again.");
    payingOrderId.value = null;
  }
}

function statusClass(status: Order["status"]): string {
  switch (status) {
    case "pending":
      return "bg-yellow-100 text-yellow-700";
    case "processing":
      return "bg-blue-100 text-blue-700";
    case "shipped":
      return "bg-indigo-100 text-indigo-700";
    case "delivered":
      return "bg-green-100 text-green-700";
    case "cancelled":
      return "bg-red-100 text-red-700";
  }
}

async function loadOrders(page = 1) {
  loading.value = true;
  error.value = "";

  try {
    const response = await getMyOrders(page);
    orders.value = response.data;
    meta.value = {
      current_page: response.current_page,
      last_page: response.last_page,
      total: response.total,
      from: response.from,
      to: response.to,
    };
  } catch {
    error.value = "Could not load your orders. Please try again.";
  } finally {
    loading.value = false;
  }
}

onMounted(() => loadOrders());
</script>
