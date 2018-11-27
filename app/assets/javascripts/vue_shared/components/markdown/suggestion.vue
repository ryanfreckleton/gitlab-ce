<script>
import Vue from 'vue';
import $ from 'jquery';
import suggestionDiff from './suggestion_diff.vue';

// TODO - Add unit tests
export default {
  components: { suggestionDiff },
  props: {
    note: {
      type: Object,
      required: false,
      default: null,
    },
    line: {
      type: Object,
      required: false,
      default: null,
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
  computed: {
    oldLineNumber() {
      let lineNumber = '';

      if (this.note && this.note.position) {
        lineNumber = this.note.position.new_line || this.note.position.old_line;
      } else if (this.line) {
        lineNumber = this.line.new_line || this.line.old_line;
      }

      return lineNumber;
    },
    oldLineContent() {
      let oldLine = '';

      if (this.line && this.line.line_code) {
        oldLine = $(`#${this.line.line_code} .line`).text();
      }

      if (this.note && this.note.suggestions && this.note.suggestions.length) {
        oldLine = this.note.suggestions[0].changing;
      }

      return oldLine;
    },
    suggestions() {
      return this.note && this.note.suggestions && this.note.suggestions.length
        ? this.note.suggestions
        : [];
    },
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

      const { oldLineNumber, oldLineContent, note, suggestions, canApply } = this;

      return new Vue({
        components: { suggestionDiff },
        data: { newLines, oldLineNumber, oldLineContent, canApply },
        computed: {
          suggestion() {
            return suggestions && suggestions[suggestionIndex] ? suggestions[suggestionIndex] : {};
          },
        },
        methods: {
          applySuggestion: ({ suggestion, callback }) => {
            const payload = {
              discussionId: note.discussion_id,
              flashContainer: this.$el,
              noteId: note.id,
              suggestion,
              callback,
            };

            this.$emit('apply', payload);
          },
        },
        template: `
          <suggestion-diff
            :new-lines="newLines"
            :old-line-content="oldLineContent"
            :old-line-number="oldLineNumber"
            :suggestion="suggestion"
            :can-apply="canApply"
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
