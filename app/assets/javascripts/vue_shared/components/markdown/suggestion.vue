<script>
import Vue from 'vue';
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
    lineNumber() {
      let lineNumber = '';

      if (this.note && this.note.position) {
        lineNumber = this.note.position.new_line || this.note.position.old_line;
      } else if (this.line) {
        lineNumber = this.line.new_line || this.line.old_line;
      }
      return lineNumber;
    },
    oldLine() {
      let oldLine = '';

      if(this.line && this.line.rich_text) {
        oldLine = this.line.rich_text;
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
      let { lineNumber } = this;
      const lines = [];
      [...newLines].forEach(line => {
        const content = `${line.innerHTML}\n`;
        lines.push({ content, lineNumber });
        lineNumber += 1;
      });
      return lines;
    },
    generateDiff(newLines, suggestionIndex) {
      const { oldLine, lineNumber } = this;
      let { canApply } = this;

      if(this.note && this.note.suggestions && this.note.suggestions.length) {
        canApply = canApply && this.note.suggestions[suggestionIndex].appliable;
      }

      return new Vue({
        components: { suggestionDiff },
        data: { newLines, oldLine, canApply, lineNumber },
        methods: {
          applySuggestion: data => this.applySuggestion(data),
        },
        template: `
          <suggestion-diff
            :new-lines="newLines"
            :old-line-content="oldLine"
            :old-line-number="lineNumber"
            :can-apply="canApply"
            @apply="applySuggestion"/>`,
      }).$mount().$el;
    },
    applySuggestion({ content, lineSpan }) {
      const position = this.note && this.note.position ? this.note.position : {};
      const fileName = position.new_path || position.old_path;
      const payload = this.createCommitPayload(content, lineSpan, fileName);

      this.$emit('apply', payload);
    },
    createCommitPayload(content, lineSpan, fileName) {
      const { lineNumber } = this;

      return {
        content,
        fileName,
        branch: this.getNoteableData.source_branch,
        projectPath: this.getNoteableData.source_project_full_path,
        commit_message: `Apply suggestion to ${fileName}`,
        from_line: lineNumber,
        to_line: lineNumber + lineSpan,
      };
    },
  },
};
</script>

<template>
  <div><div ref="container" v-html="suggestionHtml"></div></div>
</template>
