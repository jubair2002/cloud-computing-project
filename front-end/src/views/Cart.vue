<template>
  <div class="container mx-auto px-4 py-8">
    <!-- Breadcrumb -->
    <nav class="text-sm text-gray-500 mb-6 flex items-center gap-2" aria-label="Breadcrumb">
      <router-link to="/" class="hover:text-orange-500 transition">Home</router-link>
      <span>/</span>
      <span class="text-gray-800 font-medium">Shopping Cart</span>
    </nav>

    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-8">
      <div>
        <h1 class="font-display text-2xl md:text-3xl font-bold text-gray-900 flex items-center gap-3">
          Shopping Cart
          <span
            v-if="cartStore.count() > 0"
            class="text-sm font-semibold bg-orange-100 text-orange-600 px-3 py-1 rounded-full"
          >
            {{ cartStore.count() }} {{ cartStore.count() === 1 ? 'item' : 'items' }}
          </span>
        </h1>
        <p class="text-gray-500 text-sm mt-1">
          Review your items and proceed to checkout when you're ready.
        </p>
      </div>

      <router-link
        to="/products"
        class="inline-flex items-center gap-2 text-sm font-semibold text-orange-600 hover:text-orange-700 transition"
      >
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
        </svg>
        Continue Shopping
      </router-link>
    </div>

    <!-- Empty State -->
    <div
      v-if="cartStore.items.length === 0"
      class="bg-white rounded-2xl shadow-sm border border-gray-100 p-12 md:p-16 text-center max-w-2xl mx-auto"
    >
      <div class="w-24 h-24 bg-orange-50 rounded-full flex items-center justify-center mx-auto mb-6 text-orange-500">
        <svg class="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="1.75"
            d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"
          />
        </svg>
      </div>
      <h2 class="font-display text-2xl font-bold text-gray-800 mb-2">Your cart is empty</h2>
      <p class="text-gray-500 max-w-md mx-auto mb-8 text-sm md:text-base">
        Looks like you haven't added anything to your cart yet. Explore our wide collection of premium products and deals!
      </p>
      <router-link
        to="/products"
        class="inline-flex items-center justify-center gap-2 gradient-primary text-white font-semibold px-8 py-3.5 rounded-xl shadow-md hover:shadow-lg hover:opacity-95 transition"
      >
        <span>Start Shopping</span>
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3" />
        </svg>
      </router-link>
    </div>

    <!-- Active Cart Items (2 Columns) -->
    <div v-else class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
      <!-- Items Column (8 cols) -->
      <div class="lg:col-span-8 space-y-4">
        <!-- Table Header (desktop) -->
        <div class="hidden sm:grid sm:grid-cols-12 gap-4 px-6 py-3 bg-gray-100/75 rounded-xl text-xs font-semibold text-gray-500 uppercase tracking-wider">
          <span class="sm:col-span-6">Product</span>
          <span class="sm:col-span-2 text-center">Price</span>
          <span class="sm:col-span-2 text-center">Quantity</span>
          <span class="sm:col-span-2 text-right">Total</span>
        </div>

        <!-- Item Cards -->
        <div
          v-for="item in cartStore.items"
          :key="item.key"
          class="bg-white rounded-2xl shadow-sm border border-gray-100 p-4 sm:p-6 transition hover:shadow-md"
          :class="!item.available ? 'opacity-70 bg-gray-50/50' : ''"
        >
          <div class="flex flex-col sm:flex-row sm:items-center sm:grid sm:grid-cols-12 gap-4">
            <!-- Product Info (col 6) -->
            <div class="sm:col-span-6 flex gap-4 items-center">
              <router-link
                v-if="item.slug"
                :to="`/products/${item.slug}`"
                class="shrink-0 group overflow-hidden rounded-xl border border-gray-100"
              >
                <img
                  :src="item.image ?? '/placeholder.png'"
                  :alt="item.name"
                  class="w-20 h-20 sm:w-24 sm:h-24 object-cover group-hover:scale-105 transition duration-300"
                  :class="!item.available ? 'grayscale' : ''"
                />
              </router-link>
              <div v-else class="shrink-0 rounded-xl border border-gray-100 overflow-hidden">
                <img
                  :src="item.image ?? '/placeholder.png'"
                  :alt="item.name"
                  class="w-20 h-20 sm:w-24 sm:h-24 object-cover"
                  :class="!item.available ? 'grayscale' : ''"
                />
              </div>

              <div class="flex-1 min-w-0">
                <router-link
                  v-if="item.slug"
                  :to="`/products/${item.slug}`"
                  class="font-display font-semibold text-gray-900 hover:text-orange-600 transition line-clamp-2 text-sm sm:text-base mb-1"
                >
                  {{ item.name }}
                </router-link>
                <h3 v-else class="font-display font-semibold text-gray-900 text-sm sm:text-base mb-1">
                  {{ item.name }}
                </h3>

                <p v-if="item.variant_label" class="text-xs text-gray-500 mb-1.5 flex items-center gap-1.5">
                  <span class="inline-block w-2 h-2 rounded-full bg-orange-400"></span>
                  {{ item.variant_label }}
                </p>

                <p
                  v-if="!item.available"
                  class="inline-block bg-red-50 text-red-600 text-xs font-medium px-2 py-0.5 rounded-md"
                >
                  Item no longer available
                </p>

                <div class="flex sm:hidden items-center justify-between mt-3 pt-2 border-t border-gray-100">
                  <span class="text-orange-500 font-bold text-base">
                    ৳{{ (item.price * item.quantity).toLocaleString() }}
                  </span>
                  <button
                    @click="remove(item.key)"
                    :disabled="cartStore.isPending(item.key)"
                    class="text-gray-400 hover:text-red-500 text-xs flex items-center gap-1 transition"
                  >
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                    </svg>
                    Remove
                  </button>
                </div>
              </div>
            </div>

            <!-- Price (col 2) -->
            <div class="hidden sm:block sm:col-span-2 text-center text-sm font-medium text-gray-700">
              ৳{{ item.price.toLocaleString() }}
            </div>

            <!-- Quantity (col 2) -->
            <div class="sm:col-span-2 flex items-center sm:justify-center">
              <div v-if="item.available" class="inline-flex items-center border border-gray-200 rounded-xl bg-gray-50 overflow-hidden">
                <button
                  @click="decrease(item)"
                  :disabled="cartStore.isPending(item.key) || item.quantity <= 1"
                  class="w-8 h-8 flex items-center justify-center text-gray-600 hover:bg-white transition disabled:opacity-30 disabled:cursor-not-allowed"
                  aria-label="Decrease quantity"
                >
                  -
                </button>
                <span class="w-10 text-center font-semibold text-sm text-gray-800">
                  {{ item.quantity }}
                </span>
                <button
                  @click="increase(item)"
                  :disabled="cartStore.isPending(item.key)"
                  class="w-8 h-8 flex items-center justify-center text-gray-600 hover:bg-white transition disabled:opacity-30 disabled:cursor-not-allowed"
                  aria-label="Increase quantity"
                >
                  +
                </button>
              </div>
            </div>

            <!-- Total & Remove (col 2) -->
            <div class="hidden sm:flex sm:col-span-2 items-center justify-end gap-3">
              <span class="font-bold text-orange-500 text-base">
                ৳{{ (item.price * item.quantity).toLocaleString() }}
              </span>
              <button
                @click="remove(item.key)"
                :disabled="cartStore.isPending(item.key)"
                class="w-8 h-8 rounded-lg flex items-center justify-center text-gray-400 hover:text-red-500 hover:bg-red-50 transition disabled:opacity-40"
                title="Remove item"
                aria-label="Remove item"
              >
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                </svg>
              </button>
            </div>
          </div>
        </div>

        <!-- Actions Row -->
        <div class="flex flex-wrap items-center justify-between gap-4 pt-4">
          <router-link
            to="/products"
            class="inline-flex items-center gap-2 text-sm font-medium text-gray-600 hover:text-orange-500 transition px-4 py-2 border border-gray-300 rounded-xl hover:border-orange-300"
          >
            ← Continue Shopping
          </router-link>

          <button
            @click="clearAll"
            class="text-sm font-medium text-red-500 hover:text-red-700 transition px-4 py-2 hover:bg-red-50 rounded-xl"
          >
            Clear Entire Cart
          </button>
        </div>
      </div>

      <!-- Order Summary Column (4 cols) -->
      <div class="lg:col-span-4 sticky top-24 space-y-6">
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
          <h2 class="font-display text-xl font-bold text-gray-900 mb-4 pb-4 border-b border-gray-100">
            Order Summary
          </h2>

          <div class="space-y-3 text-sm text-gray-600">
            <div class="flex justify-between">
              <span>Subtotal ({{ cartStore.availableItems().length }} items)</span>
              <span class="font-semibold text-gray-800">৳{{ subtotalFormatted }}</span>
            </div>

            <div class="flex justify-between items-center">
              <span class="flex items-center gap-1">
                Estimated Shipping
                <span class="text-xs text-gray-400" title="Calculated at checkout">ⓘ</span>
              </span>
              <span class="text-green-600 font-semibold text-xs bg-green-50 px-2 py-0.5 rounded-full">
                Free / Standard
              </span>
            </div>

            <div class="border-t border-gray-100 pt-3 mt-3 flex justify-between items-baseline">
              <div>
                <span class="font-bold text-gray-900 text-lg">Total</span>
                <p class="text-xs text-gray-400">VAT & taxes included</p>
              </div>
              <span class="text-2xl font-bold text-orange-500">৳{{ subtotalFormatted }}</span>
            </div>
          </div>

          <button
            id="proceed-checkout-btn"
            @click="proceedToCheckout"
            :disabled="cartStore.availableItems().length === 0"
            class="mt-6 w-full gradient-primary text-white py-4 rounded-xl font-semibold shadow-md hover:shadow-lg hover:opacity-95 transition disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2 text-base"
          >
            <span>Proceed to Checkout</span>
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3" />
            </svg>
          </button>

          <p class="text-center text-xs text-gray-400 mt-3">
            Voucher discounts can be applied directly on the checkout page.
          </p>
        </div>

        <!-- Trust Badges -->
        <div class="bg-gray-50/70 border border-gray-100 rounded-2xl p-5 space-y-3.5">
          <div class="flex items-center gap-3 text-xs text-gray-600">
            <div class="w-8 h-8 rounded-lg bg-orange-100 text-orange-600 flex items-center justify-center shrink-0">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
              </svg>
            </div>
            <div>
              <p class="font-semibold text-gray-800">Secure Payment</p>
              <p class="text-gray-500">Encrypted checkout & Cash on Delivery</p>
            </div>
          </div>

          <div class="flex items-center gap-3 text-xs text-gray-600">
            <div class="w-8 h-8 rounded-lg bg-blue-100 text-blue-600 flex items-center justify-center shrink-0">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
              </svg>
            </div>
            <div>
              <p class="font-semibold text-gray-800">7-Day Easy Returns</p>
              <p class="text-gray-500">Hassle-free replacement guarantee</p>
            </div>
          </div>

          <div class="flex items-center gap-3 text-xs text-gray-600">
            <div class="w-8 h-8 rounded-lg bg-green-100 text-green-600 flex items-center justify-center shrink-0">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <div>
              <p class="font-semibold text-gray-800">100% Authentic</p>
              <p class="text-gray-500">Verified products directly from brands</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from "vue";
import { useRouter } from "vue-router";
import { useCartStore, type CartLine } from "../stores/cart";
import { useAuthStore } from "../stores/auth";

const router = useRouter();
const cartStore = useCartStore();
const auth = useAuthStore();

const subtotalFormatted = computed(() => {
  return cartStore.total().toLocaleString();
});

function increase(item: CartLine) {
  cartStore.updateQuantity(item.key, item.quantity + 1);
}

function decrease(item: CartLine) {
  cartStore.updateQuantity(item.key, item.quantity - 1);
}

function remove(key: string) {
  cartStore.removeItem(key);
}

function clearAll() {
  if (confirm("Are you sure you want to remove all items from your cart?")) {
    cartStore.clearItems();
  }
}

function proceedToCheckout() {
  // Clear any buy-now item before standard cart checkout
  cartStore.clearBuyNow();

  if (!auth.isLoggedIn) {
    router.push({
      name: "CustomerLogin",
      query: { redirect: "/checkout" },
    });
    return;
  }

  router.push("/checkout");
}
</script>
