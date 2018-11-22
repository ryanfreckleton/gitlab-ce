<script>
import Vue from 'vue';
import { mapGetters, mapActions } from 'vuex';
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
      required: true
    },
  },
  computed: {
    ...mapGetters(['getNoteableData']),
    canApply() {
      return Boolean(this.note && this.note.position);
    },
    lineNumber() {
      let lineNumber = '';

      if(this.note && this.note.position) {
        lineNumber =  this.note.position.new_line || this.note.position.old_line;
      } else if(this.line) {
        lineNumber = this.line.new_line || this.line.old_line;;
      }
      return lineNumber;
    }
  },
  mounted() {
    this.renderSuggestions();
  },
  methods: {
    renderSuggestions() {
      const { container } = this.$refs;
      const suggestions = container.getElementsByClassName('suggestion');

      [...suggestions].forEach(suggestionEl => {
         const newLine = this.extractNewLine(suggestionEl);
         container.insertBefore(this.generateDiff(newLine), suggestionEl);
         container.removeChild(suggestionEl);
      });
    },
    extractNewLine(suggestionEl) {
      const newLine = suggestionEl.getElementsByClassName('line');
      const content = (newLine && newLine[0]) ? newLine[0].innerHTML : '';
      const number = this.lineNumber;
      return { content, number };
    },
    generateDiff(newLine) {
      const { canApply } = this;

      return new Vue({
        components: { suggestionDiff },
        data: { newLine, canApply },
        methods: {
          applySuggestion: content => this.applySuggestion(content)
        },
        template: `
          <suggestion-diff
            :new-line="newLine"
            :can-apply="canApply"
            @apply="applySuggestion"/>`,
      }).$mount().$el;
    },
    applySuggestion(content) {
      const position = (this.note && this.note.position) ? this.note.position : {};
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
  <div>
    <div
      ref="container"
      v-html="suggestionHtml"
    ></div>
  </div>
</template>
