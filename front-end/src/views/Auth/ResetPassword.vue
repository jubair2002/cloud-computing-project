<template>
  <div class="container mx-auto px-4 py-12">
    <div class="max-w-lg mx-auto bg-white p-8 sm:p-10 rounded-3xl shadow-sm border border-gray-100">
      <h1 class="text-2xl sm:text-3xl font-bold text-center mb-2 font-display text-gradient-primary">
        Reset Password
      </h1>
      <p class="text-sm text-gray-500 text-center mb-6">
        Create a new, secure password for your account.
      </p>

      <div v-if="!token || !email" class="text-sm text-red-500 text-center p-4 bg-red-50 rounded-2xl border border-red-200">
        This reset link is invalid or incomplete. Please request a new one from the
        <router-link to="/forgot-password" class="underline font-semibold">forgot password</router-link> page.
      </div>

      <template v-else>
        <div v-if="errorMessage" class="mb-4 p-3.5 rounded-xl bg-red-50 border border-red-200 text-red-600 text-sm text-center">
          {{ errorMessage }}
        </div>

        <form @submit.prevent="handleSubmit" class="space-y-4">
          <div>
            <label class="block mb-1.5 text-xs font-semibold text-gray-600 uppercase tracking-wider" for="password">New Password</label>
            <input
              v-model="password"
              id="password"
              type="password"
              required
              minlength="8"
              autocomplete="new-password"
              class="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-orange-400 text-sm transition"
              placeholder="At least 8 characters"
            />
          </div>

          <div>
            <label class="block mb-1.5 text-xs font-semibold text-gray-600 uppercase tracking-wider" for="password_confirmation">Confirm New Password</label>
            <input
              v-model="passwordConfirmation"
              id="password_confirmation"
              type="password"
              required
              minlength="8"
              autocomplete="new-password"
              class="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-orange-400 text-sm transition"
              placeholder="Repeat your new password"
            />
          </div>

          <button
            type="submit"
            :disabled="loading"
            class="w-full gradient-primary text-white py-3 rounded-xl font-semibold shadow hover:opacity-90 transition disabled:opacity-50 text-sm"
          >
            {{ loading ? "Resetting password..." : "Reset Password" }}
          </button>
        </form>
      </template>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from "vue";
import { useRoute, useRouter } from "vue-router";
import { resetPassword, firstValidationError } from "../../services/account";

const route = useRoute();
const router = useRouter();

const token = computed(() => (route.query.token as string) || "");
const email = computed(() => (route.query.email as string) || "");

const password = ref("");
const passwordConfirmation = ref("");
const errorMessage = ref("");
const loading = ref(false);

async function handleSubmit() {
  errorMessage.value = "";
  loading.value = true;

  try {
    await resetPassword({
      token: token.value,
      email: email.value,
      password: password.value,
      password_confirmation: passwordConfirmation.value,
    });

    router.push({ path: "/login", query: { reset: "1" } });
  } catch (error) {
    errorMessage.value = firstValidationError(
      error,
      "Reset failed. The link may have expired — request a new one."
    );
  } finally {
    loading.value = false;
  }
}
</script>
