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
      // see https://docs.gitlab.com/ce/api/repository_files.html
      const position = (this.note && this.note.position) ? this.note.position : {};
      const fileName = position.new_path || position.old_path;
      const commitPayload = this.createCommitPayload(content, fileName);
      console.log('applying suggestion > ', commitPayload, fileName);

      // TODO - Dispatch > Apply suggestion
    },
    createCommitPayload(content, fileName) {
      const { lineNumber } = this;

      return {
        content,
        branch: this.getNoteableData.source_branch,
        commit_message: `Apply suggestion to ${fileName}`, // TODO - make this user-defined?
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
      class="md-suggestion-diff"
      v-html="suggestionHtml"
    ></div>
  </div>
</template>
