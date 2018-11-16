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
//

export default function renderSuggestion($els, metadata) {
  if (!$els.length || !metadata.fileName) return;

  const { fileName, canApply } = metadata;

  const applySuggestion = () => {
    // TODO - Apply suggestion
  };

  const generateHeader = () =>
    new Vue({
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

  $els.each((i, el) => {
    const prevSibling = el.previousElementSibling;
    if (prevSibling.classList.contains('suggestion-header')) {
      prevSibling.remove();
    }
    el.parentNode.insertBefore(generateHeader(), el);
  });
}
