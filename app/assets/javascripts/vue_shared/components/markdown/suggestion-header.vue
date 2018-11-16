<script>
export default {
  props: {
    fileName: {
      type: String,
      required: false,
      default: '',
    },
    canApply: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  methods: {
    applySuggestion() {
      this.$emit('apply');
    },
  },
};
</script>

<template>
  <div>
    <div class="file-title-flex-parent md-suggestion-header border-bottom-0 mt-2">
      {{ fileName }}
      <button
        v-if="canApply"
        type="button"
        class="btn"
        @click="applySuggestion">Apply</button>
    </div>
  </div>
</template>
