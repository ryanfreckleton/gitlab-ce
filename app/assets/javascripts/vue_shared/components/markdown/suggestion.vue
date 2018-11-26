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
      return this.line && this.line.rich_text ? this.line.rich_text : '';
    },
  },
  mounted() {
    this.renderSuggestions();
  },
  methods: {
    renderSuggestions() {
      const { container } = this.$refs;
      const suggestionElements = container.getElementsByClassName('suggestion');

      [...suggestionElements].forEach(suggestionEl => {
        container.insertBefore(this.generateDiff(this.extractNewLines(suggestionEl)), suggestionEl);
        container.removeChild(suggestionEl);
      });
    },
    extractNewLines(suggestionEl) {
      const newLines = suggestionEl.getElementsByClassName('line');
      let { lineNumber } = this;
      const lines = [];
      [...newLines].forEach(line => {
        const content = `${line.innerHTML} \n`;
        lines.push({ content, lineNumber });
        lineNumber += 1;
      });
      return lines;
    },
    generateDiff(newLines) {
      const { canApply, oldLine, lineNumber } = this;

      return new Vue({
        components: { suggestionDiff },
        data: { newLines, oldLine, canApply, lineNumber },
        methods: {
          applySuggestion: content => this.applySuggestion(content),
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
    applySuggestion(content) {
      const position = this.note && this.note.position ? this.note.position : {};
      const fileName = position.new_path || position.old_path;
      const payload = this.createCommitPayload(content, fileName);

      this.$emit('apply', payload);
    },
    createCommitPayload(content, fileName) {
      const { lineNumber } = this;

      return {
        content,
        fileName,
        branch: this.getNoteableData.source_branch,
        projectPath: this.getNoteableData.source_project_full_path,
        commit_message: `Apply suggestion to ${fileName}`,
        from_line: lineNumber,
        to_line: lineNumber,
      };
    },
  },
};
</script>

<template>
  <div><div ref="container" v-html="suggestionHtml"></div></div>
</template>
