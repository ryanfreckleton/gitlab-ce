<script>
import suggestionDiffHeader from './suggestion_diff_header.vue';

export default {
  components: {
    suggestionDiffHeader,
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
  },
  methods: {

    applySuggestion() {
      let content = '';
      const lineSpan = this.newLines.length -1;

      this.newLines.forEach(line => {
        content += line.content;
      });

      this.$emit('apply', { content, lineSpan });
    },
  },
};
</script>

<template>
  <div>
    <suggestion-diff-header :can-apply="canApply" @apply="applySuggestion" />
    <table class="mb-3 md-suggestion-diff">
      <tbody>
        <!-- Old Line -->
        <tr class="line_holder old">
          <td class="diff-line-num old_line old">
            {{ oldLineNumber }}
          </td>
          <td class="diff-line-num new_line qa-new-diff-line old"></td>
          <td
            class="line_content old"
            v-html="oldLineContent">
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
          <td
            class="line_content new"
            v-html="line.content">
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
