<script>
import Icon from '~/vue_shared/components/icon.vue';

export default {
  components: { Icon },
  props: {
    canApply: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    return {
      isApplied: false,
      isApplying: false,
    };
  },
  methods: {
    applySuggestion() {
      if(!this.canApply) return;
      this.isApplying = true;
      this.$emit('apply', isSuccess => this.suggestionApplied(isSuccess));
    },
    suggestionApplied(isSuccess) {
      this.isApplied = isSuccess;
      this.isApplying = false;
    },
  },
};
</script>

<template>
  <div class="file-title-flex-parent md-suggestion-header border-bottom-0 mt-2">
    <div class="qa-suggestion-diff-header">Suggested change <icon name="question-o" css-classes="link-highlight" /></div>
    <button
      v-if="canApply && !isApplied"
      type="button"
      class="btn qa-apply-btn"
      :disabled="isApplying"
      @click="applySuggestion"
    >
      Apply suggestion
    </button>
  </div>
</template>
