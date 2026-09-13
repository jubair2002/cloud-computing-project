<template>
  <div class="container mx-auto px-4 py-8">
    <!-- Breadcrumb -->
    <nav class="text-sm text-gray-500 mb-6 flex items-center gap-2" aria-label="Breadcrumb">
      <router-link to="/" class="hover:text-orange-500 transition">Home</router-link>
      <span>/</span>
      <span class="text-gray-800 font-medium">My Account</span>
    </nav>

    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
      <div>
        <h1 class="font-display text-2xl md:text-3xl font-bold text-gray-900">
          Account Settings
        </h1>
        <p class="text-gray-500 text-sm mt-1">
          Manage your personal information, shipping preferences, and security settings.
        </p>
      </div>

      <div class="flex items-center gap-3 bg-white border border-gray-200/80 px-4 py-2.5 rounded-2xl shadow-sm">
        <div class="w-10 h-10 rounded-full gradient-primary text-white font-bold flex items-center justify-center text-base">
          {{ userInitial }}
        </div>
        <div>
          <p class="font-semibold text-sm text-gray-900 leading-tight">{{ auth.user?.name }}</p>
          <p class="text-xs text-gray-500">{{ auth.user?.email }}</p>
        </div>
      </div>
    </div>

    <AccountNav />

    <div
      v-if="isDemoAccount"
      class="mb-6 p-4 rounded-2xl bg-orange-50 border border-orange-200 text-sm text-gray-700 flex items-center gap-3"
    >
      <span class="text-xl">ℹ️</span>
      <span>
        You're signed in with the <strong class="font-semibold text-orange-800">shared demo account</strong> —
        profile details and password can't be changed, so it stays working for every visitor.
      </span>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
      <!-- Profile Details Card (7 cols) -->
      <div class="lg:col-span-7 bg-white p-6 sm:p-8 rounded-2xl shadow-sm border border-gray-100">
        <div class="flex items-center gap-3 mb-6 pb-4 border-b border-gray-100">
          <div class="w-10 h-10 rounded-xl bg-orange-50 text-orange-500 flex items-center justify-center">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
            </svg>
          </div>
          <div>
            <h2 class="font-display text-lg font-bold text-gray-900">Personal Information</h2>
            <p class="text-xs text-gray-500">Update your name, email, and primary shipping destination</p>
          </div>
        </div>

        <div v-if="profileSuccess" class="mb-4 p-3.5 rounded-xl bg-green-50 border border-green-200 text-green-700 text-sm flex items-center gap-2">
          <span>✓</span>
          <span>Profile details saved successfully.</span>
        </div>
        <div v-if="profileError" class="mb-4 p-3.5 rounded-xl bg-red-50 border border-red-200 text-red-600 text-sm">
          {{ profileError }}
        </div>

        <form @submit.prevent="saveProfile">
          <fieldset :disabled="isDemoAccount" class="space-y-4 disabled:opacity-60">
            <div>
              <label class="block text-xs font-semibold text-gray-600 uppercase tracking-wider mb-1.5" for="name">
                Full Name
              </label>
              <input
                v-model="profileForm.name"
                id="name"
                type="text"
                required
                class="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-orange-400 focus:border-transparent text-sm transition"
              />
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label class="block text-xs font-semibold text-gray-600 uppercase tracking-wider mb-1.5" for="email">
                  Email Address
                </label>
                <input
                  v-model="profileForm.email"
                  id="email"
                  type="email"
                  required
                  class="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-orange-400 focus:border-transparent text-sm transition"
                />
              </div>

              <div>
                <label class="block text-xs font-semibold text-gray-600 uppercase tracking-wider mb-1.5" for="phone">
                  Phone Number
                </label>
                <input
                  v-model="profileForm.phone"
                  id="phone"
                  type="tel"
                  placeholder="01XXXXXXXXX"
                  class="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-orange-400 focus:border-transparent text-sm transition"
                />
              </div>
            </div>

            <div>
              <label class="block text-xs font-semibold text-gray-600 uppercase tracking-wider mb-1.5" for="default_shipping_address">
                Default Shipping Address
              </label>
              <textarea
                v-model="profileForm.default_shipping_address"
                id="default_shipping_address"
                rows="3"
                class="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-orange-400 focus:border-transparent text-sm transition"
                placeholder="Street address, apartment, city, postal code"
              ></textarea>
              <p class="text-xs text-gray-400 mt-1">This address will be auto-filled during checkout.</p>
            </div>

            <div class="pt-2">
              <button
                type="submit"
                :disabled="savingProfile"
                class="gradient-primary text-white font-semibold px-6 py-2.5 rounded-xl shadow-sm hover:opacity-90 transition disabled:opacity-50 text-sm"
              >
                {{ savingProfile ? "Saving changes..." : "Save Profile Changes" }}
              </button>
            </div>
          </fieldset>
        </form>
      </div>

      <!-- Change Password Card (5 cols) -->
      <div class="lg:col-span-5 bg-white p-6 sm:p-8 rounded-2xl shadow-sm border border-gray-100">
        <div class="flex items-center gap-3 mb-6 pb-4 border-b border-gray-100">
          <div class="w-10 h-10 rounded-xl bg-blue-50 text-blue-500 flex items-center justify-center">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
            </svg>
          </div>
          <div>
            <h2 class="font-display text-lg font-bold text-gray-900">Security & Password</h2>
            <p class="text-xs text-gray-500">Ensure your account remains safe</p>
          </div>
        </div>

        <div v-if="passwordSuccess" class="mb-4 p-3.5 rounded-xl bg-green-50 border border-green-200 text-green-700 text-sm flex items-center gap-2">
          <span>✓</span>
          <span>Password updated successfully.</span>
        </div>
        <div v-if="passwordError" class="mb-4 p-3.5 rounded-xl bg-red-50 border border-red-200 text-red-600 text-sm">
          {{ passwordError }}
        </div>

        <form @submit.prevent="savePassword">
          <fieldset :disabled="isDemoAccount" class="space-y-4 disabled:opacity-60">
            <div>
              <label class="block text-xs font-semibold text-gray-600 uppercase tracking-wider mb-1.5" for="current_password">
                Current Password
              </label>
              <input
                v-model="passwordForm.current_password"
                id="current_password"
                type="password"
                required
                autocomplete="current-password"
                class="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-orange-400 focus:border-transparent text-sm transition"
              />
            </div>

            <div>
              <label class="block text-xs font-semibold text-gray-600 uppercase tracking-wider mb-1.5" for="new_password">
                New Password
              </label>
              <input
                v-model="passwordForm.password"
                id="new_password"
                type="password"
                required
                minlength="8"
                autocomplete="new-password"
                class="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-orange-400 focus:border-transparent text-sm transition"
                placeholder="At least 8 characters"
              />
            </div>

            <div>
              <label class="block text-xs font-semibold text-gray-600 uppercase tracking-wider mb-1.5" for="new_password_confirmation">
                Confirm New Password
              </label>
              <input
                v-model="passwordForm.password_confirmation"
                id="new_password_confirmation"
                type="password"
                required
                minlength="8"
                autocomplete="new-password"
                class="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-orange-400 focus:border-transparent text-sm transition"
              />
            </div>

            <div class="pt-2">
              <button
                type="submit"
                :disabled="savingPassword"
                class="border-2 border-orange-500 text-orange-600 font-semibold px-6 py-2.5 rounded-xl hover:bg-orange-50 transition disabled:opacity-50 text-sm"
              >
                {{ savingPassword ? "Updating password..." : "Change Password" }}
              </button>
            </div>
          </fieldset>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from "vue";
import { useAuthStore } from "../../stores/auth";
import { updateProfile, changePassword, firstValidationError } from "../../services/account";
import { useDemoAccount } from "../../composables/useDemoAccount";
import AccountNav from "../../components/account/AccountNav.vue";

const auth = useAuthStore();
const { isDemoAccount } = useDemoAccount();

const userInitial = computed(() => {
  const name = auth.user?.name || "U";
  return name.charAt(0).toUpperCase();
});

const profileForm = ref({
  name: auth.user?.name ?? "",
  email: auth.user?.email ?? "",
  phone: auth.user?.phone ?? "",
  default_shipping_address: auth.user?.default_shipping_address ?? "",
});
const savingProfile = ref(false);
const profileSuccess = ref(false);
const profileError = ref("");

const passwordForm = ref({
  current_password: "",
  password: "",
  password_confirmation: "",
});
const savingPassword = ref(false);
const passwordSuccess = ref(false);
const passwordError = ref("");

async function saveProfile() {
  if (isDemoAccount.value) return;
  profileSuccess.value = false;
  profileError.value = "";
  savingProfile.value = true;

  try {
    const updated = await updateProfile(profileForm.value);
    auth.setUser(updated);
    profileSuccess.value = true;
  } catch (e) {
    profileError.value = firstValidationError(e, "Could not save your profile.");
  } finally {
    savingProfile.value = false;
  }
}

async function savePassword() {
  if (isDemoAccount.value) return;
  passwordSuccess.value = false;
  passwordError.value = "";
  savingPassword.value = true;

  try {
    await changePassword(passwordForm.value);
    passwordSuccess.value = true;
    passwordForm.value = { current_password: "", password: "", password_confirmation: "" };
  } catch (e) {
    passwordError.value = firstValidationError(e, "Could not update your password.");
  } finally {
    savingPassword.value = false;
  }
}
</script>
