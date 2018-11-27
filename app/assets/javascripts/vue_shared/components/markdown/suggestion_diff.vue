<script>
import _ from 'underscore';
import suggestionDiffHeader from './suggestion_diff_header.vue';

export default {
  components: {
    suggestionDiffHeader,
  },
  filters: {
    unescape: value => _.unescape(value)
  },
  props: {
    canApply: {
      type: Boolean,
      required: false,
      default: false,
    },
    newLines: {
      type: Array,
      required: true,
    },
    oldLineContent: {
      type: String,
      required: false,
      default: '',
    },
    oldLineNumber: {
      type: Number,
      required: true,
    },
    suggestion: {
      type: Object,
      required: true
    },
  },
  methods: {
    applySuggestion(callback) {
      this.$emit('apply', this.suggestion.id, callback);
    },
  },
};
</script>

<template>
  <div>
    <suggestion-diff-header
      :can-apply="canApply && suggestion.appliable"
      @apply="applySuggestion" />
    <table class="mb-3 md-suggestion-diff">
      <tbody>
        <!-- Old Line -->
        <tr class="line_holder old">
          <td class="diff-line-num old_line old">
            {{ oldLineNumber }}
          </td>
          <td class="diff-line-num new_line qa-new-diff-line old"></td>
          <td class="line_content old">
            <span>{{ oldLineContent | unescape }}</span>
          </td>
        </tr>
        <!-- New Line -->
        <tr
          v-for="(line, key) of newLines"
          :key="key"
          class="line_holder new">
          <td class="diff-line-num old_line new"></td>
          <td class="diff-line-num new_line qa-new-diff-line new">
            {{ line.lineNumber }}
          </td>
          <td class="line_content new">
            <span>{{ line.content | unescape }}</span>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
