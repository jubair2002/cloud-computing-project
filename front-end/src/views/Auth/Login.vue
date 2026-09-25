<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50 px-4 py-12">
    <div class="max-w-md w-full bg-white p-8 sm:p-10 rounded-3xl shadow-sm border border-gray-100">
      <div class="text-center mb-6">
        <div class="inline-flex items-center justify-center w-12 h-12 rounded-2xl gradient-primary text-white font-bold text-xl mb-3 shadow-md">
          S
        </div>
        <h1 class="text-2xl sm:text-3xl font-bold font-display text-gray-800">
          Admin Portal
        </h1>
        <p class="text-sm text-gray-500 mt-1">Sign in with your administrator credentials</p>
      </div>

      <!-- Demo mode -->
      <div
        v-if="demoConfig?.demo_mode && demoConfig?.demo_admin_email"
        class="mb-6 p-4 rounded-xl bg-orange-50 border border-orange-200 text-center"
      >
        <p class="text-sm text-gray-600 mb-3">
          This is a portfolio demo — explore the admin panel instantly.
        </p>
        <button
          type="button"
          :disabled="loading"
          class="w-full gradient-primary text-white py-2.5 rounded-xl font-semibold hover:opacity-90 transition disabled:opacity-50 text-sm shadow-sm"
          @click="handleDemoLogin"
        >
          {{ loading ? "Logging in..." : "Try Demo Admin Login" }}
        </button>
      </div>

      <div
        v-if="demoConfig?.demo_mode && demoConfig?.demo_admin_email"
        class="flex items-center gap-3 mb-6"
      >
        <div class="flex-1 h-px bg-gray-200"></div>
        <span class="text-xs text-gray-400 uppercase tracking-wider">or sign in manually</span>
        <div class="flex-1 h-px bg-gray-200"></div>
      </div>

      <!-- Error Message -->
      <div
        v-if="errorMessage"
        class="mb-4 p-3 rounded-xl bg-red-50 border border-red-200 text-red-600 text-sm text-center"
      >
        {{ errorMessage }}
      </div>

      <form @submit.prevent="handleLogin" class="space-y-4">
        <div>
          <label class="block mb-1.5 text-xs font-semibold text-gray-600 uppercase tracking-wider" for="email">
            Admin Email
          </label>
          <input
            v-model="email"
            id="email"
            type="email"
            required
            autocomplete="username"
            class="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-orange-400 text-sm transition"
            placeholder="admin@shophub.test"
          />
        </div>

        <div>
          <label class="block mb-1.5 text-xs font-semibold text-gray-600 uppercase tracking-wider" for="password">
            Password
          </label>
          <input
            v-model="password"
            id="password"
            type="password"
            required
            autocomplete="current-password"
            class="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-orange-400 text-sm transition"
            placeholder="••••••••"
          />
        </div>

        <button
          type="submit"
          :disabled="loading"
          class="w-full gradient-primary text-white py-3 rounded-xl font-semibold shadow hover:opacity-90 transition disabled:opacity-50 text-sm"
        >
          {{ loading ? "Signing in..." : "Sign In to Admin" }}
        </button>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import { useAuthStore } from "../../stores/auth";
import { useToastStore } from "../../stores/toast";
import { getAppConfig, type AppConfig } from "../../services/config";
import type { AxiosError } from "axios";

const auth = useAuthStore();
const router = useRouter();

const email = ref("");
const password = ref("");
const errorMessage = ref("");
const loading = ref(false);
const demoConfig = ref<AppConfig | null>(null);

onMounted(async () => {
  if (auth.isAdmin) {
    router.replace("/admin");
    return;
  }

  try {
    demoConfig.value = await getAppConfig();
  } catch {
    demoConfig.value = null;
  }
});

async function handleDemoLogin() {
  if (!demoConfig.value?.demo_admin_email || !demoConfig.value.demo_admin_password) return;

  email.value = demoConfig.value.demo_admin_email;
  password.value = demoConfig.value.demo_admin_password;
  await handleLogin();
}

async function handleLogin() {
  errorMessage.value = "";
  loading.value = true;

  try {
    await auth.adminLogin({
      email: email.value,
      password: password.value,
    });

    if (!auth.isAdmin) {
      await auth.logout();
      errorMessage.value = "Access denied. Administrator privileges required.";
      return;
    }

    useToastStore().success(`Welcome back, ${auth.user?.name ?? "Admin"}!`);
    router.push("/admin");
  } catch (error) {
    const err = error as AxiosError<{ message?: string }>;
    errorMessage.value =
      err.response?.data?.message || (error as Error).message || "Login failed. Try again.";
  } finally {
    loading.value = false;
  }
}
</script>
