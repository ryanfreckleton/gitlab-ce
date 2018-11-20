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

export default {
  props: {
    fileName: {
      type: String,
      required: false,
      default: '',
    },
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
    this.renderHeaders();
  },
  methods: {
    renderHeaders() {
      if(!this.fileName) return;

      const container = this.$slots.default[0].elm;
      const suggestions = container.getElementsByClassName('js-render-suggestion');
      [...suggestions].forEach(suggestion => container.insertBefore(this.generateHeader(), suggestion));
    },
    generateHeader() {
      const { fileName, canApply } = this;
      return new Vue({
        components: {
          suggestionHeader,
        },
        data: {
          fileName,
          canApply,
        },
        methods: {
          applySuggestion: this.applySuggestion
        },
        template: `
          <suggestion-header
            :file-name="fileName"
            :can-apply="canApply"
            @apply="applySuggestion"
          />`,
      }).$mount().$el;
    },
    applySuggestion() {
      const { position } = this.note;
      const lineNumber = position.new_line || position.old_line;

      console.log('applying suggestion > ', {lineNumber});

      // TODO - Get/Set new line content
      // TODO - Dispatch > Apply suggestion
    },
  },
};

</script>

<template>
  <div>
    <slot></slot>
  </div>
</template>
