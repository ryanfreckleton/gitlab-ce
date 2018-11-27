<script>
import Vue from 'vue';
import $ from 'jquery';
import { mapGetters } from 'vuex';
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
  },
  computed: {
    ...mapGetters(['getNoteableData']),
    canApply() {
      return Boolean(this.note && this.note.position);
    },
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

      if(this.line && this.line.line_code) {
        oldLine = $(`#${this.line.line_code} .line`).text();
      }

      if(this.note && this.note.suggestions && this.note.suggestions.length) {
        oldLine = this.note.suggestions[0].changing;
      }

      return oldLine;
    },
  },
  mounted() {
    this.renderSuggestions();
  },
  methods: {
    renderSuggestions() {
      // swaps out suggestion markdown with rich diff components
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
      const newLines = suggestionEl.getElementsByClassName('line');
      let lineNumber = this.oldLineNumber;
      const lines = [];
      [...newLines].forEach(line => {
        const content = `${line.innerHTML}\n`;
        lines.push({ content, lineNumber });
        lineNumber += 1;
      });
      return lines;
    },
    generateDiff(newLines, suggestionIndex) {
      const { oldLineNumber, oldLineContent } = this;
      let { canApply } = this;
      let suggestionId;

      if(this.note && this.note.suggestions && this.note.suggestions.length) {
        canApply = canApply && this.note.suggestions[suggestionIndex].appliable;
        suggestionId = this.note.suggestions[suggestionIndex].id;
      }

      return new Vue({
        components: { suggestionDiff },
        data: { newLines, oldLineNumber, oldLineContent, canApply },
        methods: {
          applySuggestion: callback => this.$emit('apply', {id: suggestionId, flashContainer: this.$el, callback}),
        },
        template: `
          <suggestion-diff
            :new-lines="newLines"
            :old-line-content="oldLineContent"
            :old-line-number="oldLineNumber"
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
