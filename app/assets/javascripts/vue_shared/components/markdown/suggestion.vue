<script>
import Vue from 'vue';
import suggestionDiff from './suggestion_diff.vue';

// TODO - Add unit tests
export default {
  components: { suggestionDiff },
  props: {
    oldLineNumber: {
      type: Number,
      required: true,
    },
    oldLineContent: {
      type: String,
      required: false,
      default: '',
    },
    suggestions: {
      type: Array,
      required: false,
      default: () => [],
    },
    suggestionHtml: {
      type: String,
      required: true,
    },
    canApply: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  watch: {
    suggestions() {
      console.log('suggestions updated > ', this.suggestions);
    }
  },
  mounted() {
    this.renderSuggestions();
  },
  methods: {
    renderSuggestions() {
      // swaps out suggestion(s) markdown with rich diff components
      // (while still keeping non-suggestion markdown in place)

      const { container } = this.$refs;
      const suggestionElements = container.getElementsByClassName('suggestion');

      [...suggestionElements].forEach((suggestionEl, i) => {
        const newLines = this.extractNewLines(suggestionEl);
        const diffComponent = this.generateDiff(newLines, i);
        container.insertBefore(diffComponent, suggestionEl);
        container.removeChild(suggestionEl);
      });
    },
    extractNewLines(suggestionEl) {
      // extracts the suggested lines from the markdown
      // calculates a line number for each line

      const newLines = suggestionEl.getElementsByClassName('line');
      const lines = [];

      [...newLines].forEach((line, i) => {
        const content = `${line.innerHTML}\n`;
        const lineNumber = this.oldLineNumber + i;
        lines.push({ content, lineNumber });
      });

      return lines;
    },
    generateDiff(newLines, suggestionIndex) {
      // generates the diff <suggestion-diff /> component
      // all `suggestion` markdown will be swapped out by this component

      const { oldLineNumber, oldLineContent, suggestions, canApply } = this;

      return new Vue({
        components: { suggestionDiff },
        data: { newLines, oldLineNumber, oldLineContent, canApply },
        computed: {
          suggestion() {
            return suggestions && suggestions[suggestionIndex] ? suggestions[suggestionIndex] : {};
          },
          hasApplied() {
            return suggestions.find(suggestion => suggestion.applied === true);
          }
        },
        methods: {
          applySuggestion: (suggestionId, callback) => {
            const payload = {
              flashContainer: this.$el,
              suggestionId,
              callback,
            };

            this.$emit('apply', payload);
          },
        },
        template: `
          <suggestion-diff
            :new-lines="newLines"
            :old-line-content="suggestion.changing || oldLineContent"
            :old-line-number="oldLineNumber"
            :suggestion="suggestion"
            :can-apply="canApply && !hasApplied"
            @apply="applySuggestion"/>`,
      }).$mount().$el;
    },
  },
};
</script>

<template>
  <div>
    <div class="flash-container mt-3"></div>
    <div ref="container" v-html="suggestionHtml"></div>
  </div>
</template>
