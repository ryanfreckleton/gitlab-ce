import Vue from 'vue';
import suggestionHeader from '~/vue_shared/components/markdown/suggestion-header.vue';

// Renders suggestions from element with the
// `js-render-suggestion` class.
//
// Example markup:
//
// I suggest we do the following:
// ```suggestion
//  const foo = 'bar';
// ```

export default function renderSuggestion($els, metadata) {
  if (!$els.length || !metadata.fileName) return;

  const { fileName, note } = metadata;

  const applySuggestion = () => {
    const { position } = note;
    const lineNumber = position.new_line || position.old_line;

    // TODO - Get/Set new line content
    // TODO - Dispatch > Apply suggestion
  };

  const generateHeader = () => {

    const canApply = (typeof note !== 'undefined');

    return new Vue({
      components: {
        suggestionHeader,
      },
      data: {
        fileName,
        canApply,
      },
      methods: {
        applySuggestion,
      },
      template: `
      <suggestion-header
        :file-name="fileName"
        :can-apply="canApply"
        @apply="applySuggestion"
      />`,
    }).$mount().$el;
  };

  $els.each((i, el) => {
    const prevSibling = el.previousElementSibling;
    if (prevSibling.classList.contains('md-suggestion-header')) {
      prevSibling.remove();
    }
    el.parentNode.insertBefore(generateHeader(), el);
  });
}
