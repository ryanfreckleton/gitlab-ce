<script>
export default {
  props: {
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
  <div class="file-title-flex-parent md-suggestion-header border-bottom-0 mt-2">
    Suggested change
    <button
      v-if="canApply"
      type="button"
      class="btn"
      @click="applySuggestion">Apply suggestion</button>
  </div>
</template>
