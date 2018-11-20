<script>
import Vue from 'vue';
import suggestionHeader from './suggestion_header.vue';

// Renders suggestions from element with the
// `js-render-suggestion` class.
//
// Example markup:
//
// I suggest we do the following:
// ```suggestion
//  const foo = 'bar';
// ```
// TODO - Add unit tests
export default {
  props: {
    note: {
      type: Object,
      required: false,
      default: null,
    },
  },
  computed: {
    canApply() {
      return Boolean(this.note);
    },
  },
  mounted() {
    this.renderSuggestions();
  },
  methods: {
    renderSuggestions() {
      const container = this.$slots.default[0].elm;
      const suggestions = container.getElementsByClassName('suggestion');

      [...suggestions].forEach(suggestionEl => {
        const newLine = this.extractNewLine(suggestionEl);
        container.insertBefore(this.generateHeader(newLine), suggestionEl)
      });
    },
    extractNewLine(suggestionEl) {
      const newLine = suggestionEl.getElementsByClassName('line');
      return (newLine && newLine[0]) ? newLine[0].innerHTML : '';
    },
    generateHeader(newLine) {
      const { canApply } = this;

      return new Vue({
        components: {
          suggestionHeader,
        },
        data: {
          canApply,
        },
        methods: {
          applySuggestion: () => this.applySuggestion(newLine)
        },
        template: `
          <suggestion-header
            :can-apply="canApply"
            @apply="applySuggestion"
          />`,
      }).$mount().$el;
    },
    applySuggestion(newLine) {
      // see https://docs.gitlab.com/ce/api/repository_files.html

      const commitPayload = this.createCommitPayload(newLine);
      console.log('applying suggestion > ', commitPayload);
      // TODO - filePath
      // TODO - Dispatch > Apply suggestion
    },
    createCommitPayload(newLine) {
      const { position } = this.note;
      const lineNumber = position.new_line || position.old_line;

      return {
        branch: 'TODO', // TODO - branchName
        content: newLine,
        commit_message: 'Aplying suggestion', // TODO - make this user-defined?
        from_line: lineNumber,
        to_line: lineNumber,
      };
    }
  },
};

</script>

<template>
  <div>
    <slot></slot>
  </div>
</template>
