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
    newLine: {
      type: Object,
      required: true,
    },
  },
  methods: {
    htmlDecode(html) {
      // converts sanitised html into readable html
      const el = document.createElement('div');
      el.innerHTML = html;
      return el.childNodes[0] ? el.childNodes[0].nodeValue : '';
    },
    applySuggestion() {
      this.$emit('apply', this.htmlDecode(this.newLine.content));
    },
  },
};
</script>

<template>
  <div>
    <suggestion-diff-header :can-apply="canApply" @apply="applySuggestion" />
    <table class="mb-3 md-suggestion-diff">
      <tbody>
        <!-- New Line -->
        <tr class="line_holder new">
          <td class="diff-line-num old_line new"></td>
          <td class="diff-line-num new_line qa-new-diff-line new">
            <div>{{ newLine.number }}</div>
          </td>
          <td class="line_content new"><span class="line" v-html="newLine.content"></span></td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
