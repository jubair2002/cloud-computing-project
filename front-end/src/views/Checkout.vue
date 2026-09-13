<template>
  <div class="container mx-auto px-4 py-8">
    <!-- Breadcrumb -->
    <nav class="text-sm text-gray-500 mb-6 flex items-center gap-2" aria-label="Breadcrumb">
      <router-link to="/" class="hover:text-orange-500 transition">Home</router-link>
      <span>/</span>
      <router-link to="/cart" class="hover:text-orange-500 transition">Cart</router-link>
      <span>/</span>
      <span class="text-gray-800 font-medium">Checkout</span>
    </nav>

    <!-- Success State: Order Placed -->
    <div
      v-if="placedOrder"
      class="bg-white rounded-3xl shadow-sm border border-gray-100 p-8 md:p-14 max-w-2xl mx-auto text-center"
    >
      <div class="w-20 h-20 bg-green-50 text-green-500 rounded-full flex items-center justify-center mx-auto mb-6">
        <svg class="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
        </svg>
      </div>

      <h1 class="font-display text-2xl md:text-3xl font-bold text-gray-900 mb-2">
        Thank you for your order!
      </h1>
      <p class="text-gray-500 text-sm md:text-base max-w-md mx-auto mb-6">
        We've received your order and are getting it ready. A confirmation email has been sent to
        <strong class="text-gray-800">{{ placedOrder.customer_email }}</strong>.
      </p>

      <div
        v-if="payRedirectFailed"
        class="text-sm text-amber-700 bg-amber-50 border border-amber-200 rounded-xl p-4 mb-6 text-left"
      >
        <p class="font-semibold mb-1">Online payment redirect note:</p>
        Your order was saved, but we couldn't immediately start the online payment redirect. You can complete the payment anytime from
        <router-link to="/account/orders" class="underline font-bold text-orange-600">My Orders</router-link>.
      </div>

      <!-- Order Details Card -->
      <div class="bg-gray-50 rounded-2xl border border-gray-100 p-6 mb-8 text-left space-y-4">
        <div class="flex flex-wrap items-center justify-between gap-2 pb-4 border-b border-gray-200/60">
          <div>
            <p class="text-xs text-gray-500 uppercase tracking-wider">Order Number</p>
            <p class="font-mono text-xl font-bold text-orange-500">{{ placedOrder.order_number }}</p>
          </div>
          <div>
            <span class="inline-block px-3 py-1 bg-green-100 text-green-700 text-xs font-semibold rounded-full capitalize">
              {{ placedOrder.status }}
            </span>
          </div>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
          <div>
            <p class="text-xs text-gray-400">Recipient</p>
            <p class="font-medium text-gray-800">{{ placedOrder.customer_name }}</p>
            <p class="text-gray-500">{{ placedOrder.customer_phone }}</p>
          </div>
          <div>
            <p class="text-xs text-gray-400">Shipping Address</p>
            <p class="font-medium text-gray-800 whitespace-pre-line">{{ placedOrder.shipping_address }}</p>
          </div>
        </div>

        <div v-if="Number(placedOrder.discount) > 0" class="pt-3 border-t border-gray-200/60 text-sm text-green-600 font-medium">
          🎉 You saved ৳{{ Number(placedOrder.discount).toLocaleString() }} with voucher {{ placedOrder.voucher_code }}!
        </div>
      </div>

      <div class="flex flex-col sm:flex-row items-center justify-center gap-4">
        <router-link
          to="/account/orders"
          class="w-full sm:w-auto gradient-primary text-white px-8 py-3.5 rounded-xl font-semibold shadow-md hover:shadow-lg hover:opacity-95 transition text-center"
        >
          View My Orders
        </router-link>
        <router-link
          to="/products"
          class="w-full sm:w-auto px-8 py-3.5 rounded-xl font-semibold border border-gray-300 text-gray-700 hover:bg-gray-50 transition text-center"
        >
          Continue Shopping
        </router-link>
      </div>
    </div>

    <!-- Empty Items State -->
    <div
      v-else-if="!cartStore.buyNowItem && cartStore.availableItems().length === 0"
      class="bg-white rounded-2xl shadow-sm border border-gray-100 p-12 text-center max-w-xl mx-auto"
    >
      <div class="w-16 h-16 bg-orange-50 text-orange-500 rounded-full flex items-center justify-center mx-auto mb-4">
        <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" />
        </svg>
      </div>
      <h2 class="font-display text-xl font-bold text-gray-800 mb-2">No items to checkout</h2>
      <p class="text-gray-500 text-sm mb-6">
        Your cart is currently empty or contains items that are no longer available.
      </p>
      <router-link
        to="/products"
        class="inline-block gradient-primary text-white px-6 py-2.5 rounded-xl font-semibold shadow hover:opacity-95 transition text-sm"
      >
        Browse Products
      </router-link>
    </div>

    <!-- Main Checkout Form (2 Columns) -->
    <div v-else>
      <div class="mb-8">
        <h1 class="font-display text-2xl md:text-3xl font-bold text-gray-900">
          {{ isBuyNow ? "Express Checkout" : "Checkout" }}
        </h1>
        <p class="text-gray-500 text-sm mt-1">
          {{ isBuyNow ? "Complete your purchase for this item." : "Provide your shipping details and select your preferred payment method." }}
        </p>
      </div>

      <form @submit.prevent="submit" class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
        <!-- Left Column: Shipping & Payment (7 cols) -->
        <div class="lg:col-span-7 space-y-6">
          <div v-if="error" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-xl text-sm">
            {{ error }}
          </div>

          <!-- Demo Account Notice -->
          <div
            v-if="isDemoAccount"
            class="p-4 rounded-xl bg-orange-50 border border-orange-200 text-xs sm:text-sm text-gray-700 flex items-center gap-3"
          >
            <span class="text-xl">ℹ️</span>
            <span>Signed in as demo account — contact and shipping fields are locked to the demo profile.</span>
          </div>

          <!-- Incomplete profile prompt -->
          <div
            v-else-if="profileIncomplete"
            class="p-4 rounded-xl bg-orange-50 border border-orange-200 text-xs sm:text-sm text-gray-700 flex items-center justify-between gap-3"
          >
            <div class="flex items-center gap-2">
              <span>💡</span>
              <span>Tip: Save your contact number & default address in your profile for instant 1-click checkout next time.</span>
            </div>
            <router-link to="/account" class="text-orange-600 font-semibold underline text-xs whitespace-nowrap">
              Edit Profile
            </router-link>
          </div>

          <!-- Contact Details Card -->
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
            <h2 class="font-display text-lg font-bold text-gray-900 mb-4 pb-3 border-b border-gray-100 flex items-center gap-2">
              <span class="w-7 h-7 rounded-full bg-orange-100 text-orange-600 flex items-center justify-center text-xs font-bold">1</span>
              Contact Information
            </h2>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div class="sm:col-span-2">
                <label class="block text-xs font-semibold text-gray-600 uppercase tracking-wider mb-1.5" for="checkout-name">
                  Full Name
                </label>
                <input
                  v-model="form.customer_name"
                  id="checkout-name"
                  type="text"
                  required
                  :readonly="isDemoAccount"
                  :class="lockedFieldClass"
                  placeholder="e.g. John Doe"
                  class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-orange-400 focus:border-transparent transition text-sm"
                />
              </div>

              <div>
                <label class="block text-xs font-semibold text-gray-600 uppercase tracking-wider mb-1.5" for="checkout-email">
                  Email Address
                </label>
                <input
                  v-model="form.customer_email"
                  id="checkout-email"
                  type="email"
                  required
                  :readonly="isDemoAccount"
                  :class="lockedFieldClass"
                  placeholder="you@example.com"
                  class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-orange-400 focus:border-transparent transition text-sm"
                />
              </div>

              <div>
                <label class="block text-xs font-semibold text-gray-600 uppercase tracking-wider mb-1.5" for="checkout-phone">
                  Phone Number
                </label>
                <input
                  v-model="form.customer_phone"
                  id="checkout-phone"
                  type="tel"
                  required
                  :readonly="isDemoAccount"
                  :class="lockedFieldClass"
                  placeholder="01XXXXXXXXX"
                  class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-orange-400 focus:border-transparent transition text-sm"
                />
              </div>
            </div>
          </div>

          <!-- Shipping Address Card -->
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
            <h2 class="font-display text-lg font-bold text-gray-900 mb-4 pb-3 border-b border-gray-100 flex items-center gap-2">
              <span class="w-7 h-7 rounded-full bg-orange-100 text-orange-600 flex items-center justify-center text-xs font-bold">2</span>
              Shipping Address
            </h2>

            <div>
              <label class="block text-xs font-semibold text-gray-600 uppercase tracking-wider mb-1.5" for="checkout-address">
                Full Street Address
              </label>
              <textarea
                v-model="form.shipping_address"
                id="checkout-address"
                required
                rows="3"
                :readonly="isDemoAccount"
                :class="lockedFieldClass"
                placeholder="House / Flat #, Road, Area, City, District"
                class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-orange-400 focus:border-transparent transition text-sm leading-relaxed"
              ></textarea>
            </div>
          </div>

          <!-- Payment Method Card -->
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
            <h2 class="font-display text-lg font-bold text-gray-900 mb-4 pb-3 border-b border-gray-100 flex items-center gap-2">
              <span class="w-7 h-7 rounded-full bg-orange-100 text-orange-600 flex items-center justify-center text-xs font-bold">3</span>
              Payment Method
            </h2>

            <div class="space-y-3">
              <!-- Cash on Delivery -->
              <label
                class="flex items-start gap-4 p-4 border rounded-xl cursor-pointer transition hover:border-orange-300"
                :class="paymentMethod === 'Cash on Delivery' ? 'border-orange-500 bg-orange-50/50 ring-1 ring-orange-500' : 'border-gray-200'"
              >
                <input
                  v-model="paymentMethod"
                  type="radio"
                  value="Cash on Delivery"
                  class="mt-1 accent-orange-500"
                />
                <div class="flex-1">
                  <div class="flex items-center gap-2">
                    <span class="font-semibold text-gray-900 text-sm">Cash on Delivery (COD)</span>
                    <span class="bg-gray-100 text-gray-600 text-xs font-medium px-2 py-0.5 rounded">Popular</span>
                  </div>
                  <p class="text-xs text-gray-500 mt-1">
                    Pay securely in cash when your order is delivered to your doorstep.
                  </p>
                </div>
              </label>

              <!-- Card (Stripe) -->
              <label
                v-if="cardPaymentsEnabled"
                class="flex items-start gap-4 p-4 border rounded-xl cursor-pointer transition hover:border-orange-300"
                :class="paymentMethod === 'Card' ? 'border-orange-500 bg-orange-50/50 ring-1 ring-orange-500' : 'border-gray-200'"
              >
                <input
                  v-model="paymentMethod"
                  type="radio"
                  value="Card"
                  class="mt-1 accent-orange-500"
                />
                <div class="flex-1">
                  <div class="flex items-center gap-2">
                    <span class="font-semibold text-gray-900 text-sm">Credit / Debit Card</span>
                    <span class="bg-blue-50 text-blue-600 text-xs font-medium px-2 py-0.5 rounded">Stripe Secure</span>
                  </div>
                  <p class="text-xs text-gray-500 mt-1">
                    Instant payment via Visa, MasterCard, AMEX, or international cards via Stripe's encrypted gateway.
                  </p>
                </div>
              </label>
            </div>
          </div>
        </div>

        <!-- Right Column: Order Summary & Action (5 cols) -->
        <div class="lg:col-span-5 sticky top-24 space-y-6">
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
            <h2 class="font-display text-lg font-bold text-gray-900 mb-4 pb-3 border-b border-gray-100 flex items-center justify-between">
              <span>Order Items ({{ checkoutItems.length }})</span>
              <router-link v-if="!isBuyNow" to="/cart" class="text-xs font-semibold text-orange-600 hover:underline">
                Edit Cart
              </router-link>
            </h2>

            <!-- Items List -->
            <div class="max-h-60 overflow-y-auto divide-y divide-gray-100 pr-1 mb-4">
              <div
                v-for="item in checkoutItems"
                :key="item.key"
                class="py-3 flex items-center gap-3"
              >
                <img
                  :src="item.image ?? '/placeholder.png'"
                  :alt="item.name"
                  class="w-14 h-14 object-cover rounded-lg border border-gray-100 shrink-0"
                />
                <div class="flex-1 min-w-0">
                  <h3 class="text-xs sm:text-sm font-semibold text-gray-900 truncate">
                    {{ item.name }}
                  </h3>
                  <p v-if="item.variant_label" class="text-xs text-gray-500">
                    {{ item.variant_label }}
                  </p>
                  <p class="text-xs text-gray-400 mt-0.5">
                    Qty: {{ item.quantity || 1 }} × ৳{{ item.price.toLocaleString() }}
                  </p>
                </div>
                <span class="font-semibold text-sm text-gray-800 shrink-0">
                  ৳{{ (item.price * (item.quantity || 1)).toLocaleString() }}
                </span>
              </div>
            </div>

            <!-- Voucher Code Section -->
            <div class="pt-4 border-t border-gray-100">
              <label class="block text-xs font-semibold text-gray-600 uppercase tracking-wider mb-2">
                Have a Voucher?
              </label>

              <div v-if="!appliedVoucher" class="flex gap-2">
                <input
                  v-model="voucherCode"
                  type="text"
                  placeholder="e.g. SAVE10"
                  class="flex-1 px-3.5 py-2 border border-gray-200 rounded-xl uppercase text-sm font-mono focus:outline-none focus:ring-2 focus:ring-orange-400"
                  @input="voucherCode = voucherCode.toUpperCase()"
                  @keydown.enter.prevent="applyVoucher"
                />
                <button
                  type="button"
                  :disabled="applyingVoucher || !voucherCode.trim()"
                  class="px-4 py-2 border-2 border-orange-500 text-orange-600 rounded-xl font-semibold text-xs hover:bg-orange-50 transition disabled:opacity-50"
                  @click="applyVoucher"
                >
                  {{ applyingVoucher ? "..." : "Apply" }}
                </button>
              </div>

              <p v-if="voucherError" class="text-red-500 text-xs mt-1.5">{{ voucherError }}</p>

              <!-- Available Vouchers List (Chips) -->
              <div v-if="!appliedVoucher && availableVouchers.length" class="mt-3 space-y-1.5">
                <p class="text-xs text-gray-400">Available vouchers for you:</p>
                <div class="space-y-1.5 max-h-36 overflow-y-auto pr-1">
                  <button
                    v-for="voucher in availableVouchers"
                    :key="voucher.code"
                    type="button"
                    class="w-full flex items-center justify-between border border-dashed border-orange-300 rounded-lg p-2 text-left hover:bg-orange-50/70 transition"
                    @click="useVoucher(voucher.code)"
                  >
                    <div class="text-xs">
                      <span class="font-mono font-bold text-orange-600">{{ voucher.code }}</span>
                      <span class="text-gray-600"> — {{ voucherSummary(voucher) }}</span>
                    </div>
                    <span class="text-xs font-bold text-orange-500 shrink-0 ml-2">Apply</span>
                  </button>
                </div>
              </div>

              <!-- Applied Voucher Badge -->
              <div
                v-if="appliedVoucher"
                class="flex items-center justify-between bg-green-50 border border-green-200 rounded-xl p-3 text-sm"
              >
                <div class="flex items-center gap-2 text-green-800">
                  <span>🎟️</span>
                  <span>Voucher <strong>{{ appliedVoucher.code }}</strong> applied</span>
                </div>
                <button
                  type="button"
                  class="text-gray-400 hover:text-red-500 text-sm p-1 transition"
                  title="Remove voucher"
                  aria-label="Remove voucher"
                  @click="removeVoucher"
                >
                  ✕
                </button>
              </div>
            </div>

            <!-- Price Breakdown -->
            <div class="pt-4 mt-4 border-t border-gray-100 space-y-2.5 text-sm text-gray-600">
              <div class="flex justify-between">
                <span>Subtotal</span>
                <span class="font-medium text-gray-800">৳{{ subtotalAmount.toLocaleString() }}</span>
              </div>

              <div v-if="appliedVoucher" class="flex justify-between text-green-600 font-medium">
                <span>Voucher Discount</span>
                <span>−৳{{ Number(appliedVoucher.discount).toLocaleString() }}</span>
              </div>

              <div class="flex justify-between">
                <span>Shipping Fee</span>
                <span class="text-green-600 font-semibold text-xs bg-green-50 px-2 py-0.5 rounded-full">Free</span>
              </div>

              <div class="pt-3 border-t border-gray-100 flex justify-between items-baseline">
                <span class="font-bold text-gray-900 text-base">Total Amount</span>
                <span class="font-bold text-2xl text-orange-500">৳{{ displayTotal.toLocaleString() }}</span>
              </div>
            </div>

            <!-- Submit Button -->
            <button
              type="submit"
              :disabled="submitting"
              class="mt-6 w-full gradient-primary text-white py-4 rounded-xl font-semibold shadow-md hover:shadow-lg hover:opacity-95 transition disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2 text-base"
            >
              <svg
                v-if="submitting"
                class="animate-spin -ml-1 mr-2 h-5 w-5 text-white"
                fill="none"
                viewBox="0 0 24 24"
              >
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              <span>{{ submitting ? "Placing Order..." : paymentMethod === "Card" ? "Continue to Payment" : "Confirm Order" }}</span>
            </button>
          </div>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from "vue";
import { useCartStore } from "../stores/cart";
import { useAuthStore } from "../stores/auth";
import { useDemoAccount } from "../composables/useDemoAccount";
import { createOrder, payOrder, type Order, type PaymentMethod } from "../services/orders";
import { getAppConfig } from "../services/config";
import {
  getPublicVouchers,
  previewVoucher,
  voucherSummary,
  type PublicVoucher,
  type VoucherPreview,
} from "../services/vouchers";

const cartStore = useCartStore();
const auth = useAuthStore();
const { isDemoAccount } = useDemoAccount();

const isBuyNow = computed(() => !!cartStore.buyNowItem);
const checkoutItems = computed(() => cartStore.checkoutItems());

const lockedFieldClass = computed(() =>
  isDemoAccount.value ? "bg-gray-50 text-gray-500 cursor-not-allowed" : ""
);

const profileIncomplete = computed(
  () => !auth.user?.phone || !auth.user?.default_shipping_address
);

const form = ref({
  customer_name: auth.user?.name ?? "",
  customer_email: auth.user?.email ?? "",
  customer_phone: auth.user?.phone ?? "",
  shipping_address: auth.user?.default_shipping_address ?? "",
});

const submitting = ref(false);
const error = ref("");
const placedOrder = ref<Order | null>(null);
const payRedirectFailed = ref(false);

const paymentMethod = ref<PaymentMethod>("Cash on Delivery");
const cardPaymentsEnabled = ref(false);

const voucherCode = ref("");
const appliedVoucher = ref<VoucherPreview | null>(null);
const voucherError = ref("");
const applyingVoucher = ref(false);
const availableVouchers = ref<PublicVoucher[]>([]);

const subtotalAmount = computed(() => cartStore.checkoutTotal());

const displayTotal = computed(() =>
  appliedVoucher.value ? Number(appliedVoucher.value.total) : subtotalAmount.value
);

function checkoutItemsPayload() {
  return checkoutItems.value.map((item) => ({
    product_id: item.id,
    variant_id: item.variant_id ?? undefined,
    quantity: item.quantity || 1,
  }));
}

async function applyVoucher() {
  const code = voucherCode.value.trim();
  if (!code || applyingVoucher.value) return;

  voucherError.value = "";
  applyingVoucher.value = true;

  try {
    appliedVoucher.value = await previewVoucher({ code, items: checkoutItemsPayload() });
  } catch (e: any) {
    voucherError.value =
      e?.response?.data?.errors?.voucher_code?.[0] ??
      e?.response?.data?.errors?.items?.[0] ??
      "Could not apply that voucher. Please try again.";
  } finally {
    applyingVoucher.value = false;
  }
}

function removeVoucher() {
  appliedVoucher.value = null;
  voucherCode.value = "";
  voucherError.value = "";
}

function useVoucher(code: string) {
  voucherCode.value = code;
  applyVoucher();
}

async function submit() {
  error.value = "";

  if (
    !form.value.customer_name.trim() ||
    !form.value.customer_phone.trim() ||
    !form.value.shipping_address.trim()
  ) {
    error.value = "Please complete your name, contact number, and shipping address.";
    return;
  }

  submitting.value = true;

  try {
    const wasBuyNow = isBuyNow.value;

    const order = await createOrder({
      ...form.value,
      payment_method: paymentMethod.value,
      ...(appliedVoucher.value ? { voucher_code: appliedVoucher.value.code } : {}),
      items: checkoutItemsPayload(),
    });

    if (wasBuyNow) {
      cartStore.clearBuyNow();
    } else {
      await cartStore.clearItems();
    }

    if (paymentMethod.value === "Card") {
      try {
        const { url } = await payOrder(order.id);
        window.location.href = url;
        return;
      } catch {
        payRedirectFailed.value = true;
      }
    }

    placedOrder.value = order;
    window.scrollTo({ top: 0, behavior: "smooth" });
  } catch (e: any) {
    error.value =
      e?.response?.data?.errors?.items?.[0] ??
      e?.response?.data?.errors?.voucher_code?.[0] ??
      e?.response?.data?.message ??
      "Something went wrong placing your order. Please try again.";
  } finally {
    submitting.value = false;
  }
}

onMounted(async () => {
  try {
    const config = await getAppConfig();
    cardPaymentsEnabled.value = config.card_payments_enabled;
  } catch {}

  try {
    availableVouchers.value = await getPublicVouchers();
  } catch {}
});
</script>
