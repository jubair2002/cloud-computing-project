<template>
  <div class="container mx-auto px-4 py-8">
    <!-- Breadcrumb -->
    <nav class="text-sm text-gray-500 mb-6 flex items-center gap-2" aria-label="Breadcrumb">
      <router-link to="/" class="hover:text-orange-500 transition">Home</router-link>
      <span>/</span>
      <span class="text-gray-800 font-medium">{{ content?.title ?? "Info" }}</span>
    </nav>

    <div class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
      <!-- Quick Navigation Sidebar (3 cols) -->
      <aside class="lg:col-span-3 bg-white rounded-2xl shadow-sm border border-gray-100 p-5 space-y-1">
        <h3 class="text-xs font-semibold text-gray-400 uppercase tracking-wider px-3 mb-3">
          Information & Support
        </h3>

        <router-link
          v-for="link in navLinks"
          :key="link.slug"
          :to="`/${link.slug}`"
          class="flex items-center justify-between px-3.5 py-2.5 rounded-xl text-sm font-medium transition"
          :class="slug === link.slug ? 'gradient-primary text-white font-semibold shadow-sm' : 'text-gray-600 hover:bg-orange-50 hover:text-orange-600'"
        >
          <span>{{ link.label }}</span>
          <span v-if="slug === link.slug" class="text-xs">→</span>
        </router-link>
      </aside>

      <!-- Main Content (9 cols) -->
      <main class="lg:col-span-9">
        <div v-if="!content" class="bg-white rounded-2xl shadow-sm border border-gray-100 p-12 text-center text-gray-400">
          Page not found.
        </div>

        <template v-else>
          <div class="mb-8">
            <h1 class="font-display text-2xl md:text-3xl font-bold text-gray-900 mb-2">
              {{ content.title }}
            </h1>
            <p class="text-gray-500 text-sm md:text-base">{{ content.tagline }}</p>
          </div>

          <!-- Job openings (careers) -->
          <div v-if="content.showJobOpenings" class="mb-8">
            <h2 class="font-display text-lg font-bold text-gray-800 mb-4">Current Job Openings</h2>
            <div v-if="jobs.length" class="space-y-4">
              <div
                v-for="job in jobs"
                :key="job.id"
                class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 transition hover:shadow-md"
              >
                <div class="flex flex-wrap items-start justify-between gap-3 mb-2">
                  <div>
                    <h3 class="font-bold text-gray-900 text-base">{{ job.title }}</h3>
                    <p class="text-xs text-gray-500">{{ job.department }}</p>
                  </div>
                  <div class="flex gap-2">
                    <span class="px-3 py-1 rounded-full text-xs font-semibold bg-orange-100 text-orange-700">
                      {{ job.employment_type }}
                    </span>
                    <span class="px-3 py-1 rounded-full text-xs font-semibold bg-gray-100 text-gray-600">
                      {{ job.location }}
                    </span>
                  </div>
                </div>
                <p class="text-sm text-gray-600 leading-relaxed mb-4">{{ job.description }}</p>
                <a
                  :href="`mailto:careers@shophub.test?subject=${encodeURIComponent(`Application: ${job.title}`)}`"
                  class="inline-flex items-center gap-1 text-sm font-semibold text-orange-600 hover:text-orange-700"
                >
                  Apply via email →
                </a>
              </div>
            </div>
            <p v-else class="bg-white rounded-2xl shadow-sm border border-gray-100 p-8 text-sm text-gray-500 text-center">
              We don't have any open positions right now — check back soon, or send us your resume anyway.
            </p>
          </div>

          <!-- FAQ style content -->
          <div v-if="content.faqs" class="space-y-3">
            <div
              v-for="(faq, i) in content.faqs"
              :key="i"
              class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden"
            >
              <button
                class="w-full flex items-center justify-between p-5 text-left font-medium text-gray-800 hover:bg-gray-50/60 transition"
                @click="openFaq = openFaq === i ? -1 : i"
              >
                <span class="font-semibold text-sm sm:text-base">{{ faq.q }}</span>
                <svg
                  class="w-5 h-5 text-gray-400 transition-transform shrink-0 ml-4"
                  :class="{ 'rotate-180 text-orange-500': openFaq === i }"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                </svg>
              </button>
              <div v-if="openFaq === i" class="px-5 pb-5 pt-1 text-sm text-gray-600 leading-relaxed border-t border-gray-50">
                {{ faq.a }}
              </div>
            </div>
          </div>

          <!-- Section style content -->
          <div v-if="content.sections" class="space-y-6">
            <div v-for="(section, i) in content.sections" :key="i" class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 sm:p-8">
              <h2 class="font-display font-bold text-lg text-gray-900 mb-3">{{ section.heading }}</h2>
              <p class="text-sm sm:text-base text-gray-600 leading-relaxed">{{ section.body }}</p>
            </div>
          </div>
        </template>
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from "vue";
import { infoPages } from "../data/infoPages";
import { getJobOpenings, type JobOpening } from "../services/careers";

const props = defineProps<{ slug: string }>();

const openFaq = ref(0);
const content = computed(() => infoPages[props.slug]);

const jobs = ref<JobOpening[]>([]);

const navLinks = [
  { slug: "help-center", label: "Help Center" },
  { slug: "returns-refunds", label: "Returns & Refunds" },
  { slug: "shipping-info", label: "Shipping Info" },
  { slug: "our-story", label: "Our Story" },
  { slug: "careers", label: "Careers" },
  { slug: "press-media", label: "Press & Media" },
  { slug: "privacy-policy", label: "Privacy Policy" },
];

// watch (not onMounted): the same component instance is reused when
// navigating between info pages.
watch(
  () => props.slug,
  async () => {
    if (!content.value?.showJobOpenings) return;
    try {
      jobs.value = await getJobOpenings();
    } catch {
      jobs.value = [];
    }
  },
  { immediate: true }
);
</script>
