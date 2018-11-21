<script>
import suggestionDiffHeader from './suggestion_diff_header.vue';

export default {
  components: {
    suggestionDiffHeader
  },
  props: {
    canApply: {
      type: Boolean,
      required: false,
      default: false,
    },
    newLine: {
      type: Object,
      required: true,
    },
  },
  methods: {
    extractNewLine(suggestionEl) {
      const newLine = suggestionEl.getElementsByClassName('line');
      return (newLine && newLine[0]) ? newLine[0].innerHTML : '';
    },
    applySuggestion() {
      this.$emit('apply', this.newLine.content);
    },
  },
};
</script>

<template>
  <div class="md-suggestion-diff-content">
    <suggestion-diff-header
      :can-apply="canApply"
      @apply="applySuggestion"
    />
    <table class="mb-3">
      <tbody>
        <!-- New Line -->
        <tr class="line_holder new">
          <td class="diff-line-num old_line new"></td>
          <td class="diff-line-num new_line qa-new-diff-line new">
            <div>
              {{ newLine.number }}
            </div>
          </td>
          <td class="line_content new">
            <span
              class="line"
              v-html="newLine.content"></span>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
