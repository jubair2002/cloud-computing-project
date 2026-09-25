<template>
  <div class="max-w-md mx-auto my-16 px-4">
    <div class="bg-white p-8 rounded-lg shadow-md text-center">
      <h1 class="text-2xl font-bold mb-4 text-gradient-primary">Signing you in...</h1>
      <p class="text-sm text-gray-600">Hang tight, this only takes a moment.</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";
import { useAuthStore } from "../../stores/auth";
import { useToastStore } from "../../stores/toast";

const auth = useAuthStore();
const toast = useToastStore();
const route = useRoute();
const router = useRouter();

const FALLBACK_ERROR = "Social sign-in failed. Please try again.";
const ERROR_MESSAGES: Record<string, string> = {
  no_email:
    "Your social account has no email address, so we can't create an account with it. Please register with email instead.",
  admin_not_allowed:
    "Admin accounts cannot sign in via social login. Please log in at /admin.",
  social_failed: FALLBACK_ERROR,
};

onMounted(async () => {
  const token = route.query.token as string | undefined;
  const error = route.query.error as string | undefined;

  // Scrub the token from the address bar before anything async happens,
  // so it never survives in browser history.
  window.history.replaceState(history.state, "", "/auth/callback");

  if (error || !token) {
    toast.error(ERROR_MESSAGES[error ?? ""] ?? FALLBACK_ERROR);
    router.replace({ name: "CustomerLogin" });
    return;
  }

  try {
    await auth.loginWithToken(token);

    if (auth.isAdmin) {
      await auth.logout();
      toast.error("Admin accounts cannot sign in here. Please log in at /admin.");
      router.replace({ name: "Login" });
      return;
    }

    toast.success(`Welcome, ${auth.user?.name ?? "shopper"}!`);

    // Only allow in-app paths ("/x", never "//host" or "scheme:") — the
    // stored value originates from an untrusted query param.
    const stored = localStorage.getItem("postLoginRedirect") || "/";
    localStorage.removeItem("postLoginRedirect");
    const target = stored.startsWith("/") && !stored.startsWith("//") ? target : "/";
    router.replace(target);
  } catch {
    toast.error("Sign-in failed. Please try again.");
    router.replace({ name: "CustomerLogin" });
  }
});
</script>
