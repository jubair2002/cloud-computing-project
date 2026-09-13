<template>
  <div class="container mx-auto px-4 py-12">
    <div class="max-w-lg mx-auto bg-white p-8 sm:p-10 rounded-3xl shadow-sm border border-gray-100">
      <h1 class="text-2xl sm:text-3xl font-bold text-center mb-2 font-display text-gradient-primary">
        Create Your Account
      </h1>
      <p class="text-center text-gray-500 text-sm mb-6">Join ShopHub to get access to exclusive deals and seamless checkout.</p>

      <SocialLoginButtons :providers="socialProviders" />

      <div v-if="socialProviders.length" class="flex items-center gap-3 mb-6">
        <div class="flex-1 h-px bg-gray-200"></div>
        <span class="text-xs text-gray-400 uppercase">or continue with email</span>
        <div class="flex-1 h-px bg-gray-200"></div>
      </div>

      <div v-if="errorMessage" class="mb-4 text-red-500 text-sm text-center">
        {{ errorMessage }}
      </div>

      <form @submit.prevent="handleRegister" class="space-y-4">
        <div>
          <label class="block mb-1.5 text-xs font-semibold text-gray-600 uppercase tracking-wider" for="name">Full Name</label>
          <input
            v-model="form.name"
            id="name"
            type="text"
            required
            autocomplete="name"
            class="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-orange-400 text-sm transition"
            placeholder="Juan Dela Cruz"
          />
        </div>

        <div>
          <label class="block mb-1.5 text-xs font-semibold text-gray-600 uppercase tracking-wider" for="email">Email</label>
          <input
            v-model="form.email"
            id="email"
            type="email"
            required
            autocomplete="username"
            class="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-orange-400 text-sm transition"
            placeholder="you@example.com"
          />
        </div>

        <div>
          <label class="block mb-1.5 text-xs font-semibold text-gray-600 uppercase tracking-wider" for="password">Password</label>
          <input
            v-model="form.password"
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
          <label class="block mb-1.5 text-xs font-semibold text-gray-600 uppercase tracking-wider" for="password_confirmation">Confirm Password</label>
          <input
            v-model="form.password_confirmation"
            id="password_confirmation"
            type="password"
            required
            minlength="8"
            autocomplete="new-password"
            class="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-orange-400 text-sm transition"
            placeholder="Repeat your password"
          />
        </div>

        <button
          type="submit"
          :disabled="loading"
          class="w-full gradient-primary text-white py-3 rounded-xl font-semibold shadow hover:opacity-90 transition disabled:opacity-50 text-sm"
        >
          {{ loading ? "Creating account..." : "Create Account" }}
        </button>
      </form>

      <p class="mt-6 text-sm text-center text-gray-600">
        Already have an account?
        <router-link to="/login" class="text-orange-500 font-semibold hover:underline">
          Sign in
        </router-link>
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from "vue";
import { useRouter } from "vue-router";
import { useAuthStore } from "../../stores/auth";
import { useToastStore } from "../../stores/toast";
import { firstValidationError } from "../../services/account";
import { getAppConfig } from "../../services/config";
import SocialLoginButtons from "../../components/auth/SocialLoginButtons.vue";

const auth = useAuthStore();
const router = useRouter();

const socialProviders = ref<string[]>([]);

onMounted(async () => {
  try {
    socialProviders.value = (await getAppConfig()).social_providers ?? [];
  } catch {
    socialProviders.value = [];
  }
});

const form = ref({
  name: "",
  email: "",
  password: "",
  password_confirmation: "",
});
const errorMessage = ref("");
const loading = ref(false);

async function handleRegister() {
  errorMessage.value = "";
  loading.value = true;

  try {
    await auth.register(form.value);
    useToastStore().success(`Welcome to ShopHub, ${auth.user?.name ?? "shopper"}!`);
    router.push("/");
  } catch (error) {
    errorMessage.value = firstValidationError(error, "Registration failed. Try again.");
  } finally {
    loading.value = false;
  }
}
</script>
