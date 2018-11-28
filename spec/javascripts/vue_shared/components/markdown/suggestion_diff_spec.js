import Vue from 'vue';
import suggestionDiffComponent from '~/vue_shared/components/markdown/suggestion_diff.vue';

const MOCK_DATA = {
  canApply: true,
  newLines: [
    { content: 'Line 1\n', lineNumber: 1 },
    { content: 'Line 2\n', lineNumber: 2 },
    { content: 'Line 3\n', lineNumber: 3 },
  ],
  oldLineNumber: 1,
  oldLineContent: 'Old content',
  suggestion: {
    id: 1,
  },
};

describe('Suggestion Diff component', () => {
  let vm;

  beforeEach(done => {
    const Component = Vue.extend(suggestionDiffComponent);

    vm = new Component({
      propsData: MOCK_DATA,
    }).$mount();

    Vue.nextTick(done);
  });

  describe('init', () => {
    it('renders a suggestion header', () => {
      expect(vm.$el.querySelector('.qa-suggestion-diff-header')).not.toBeNull();
    });

    it('renders a diff table', () => {
      expect(vm.$el.querySelector('table.md-suggestion-diff')).not.toBeNull();
    });

    it('renders the oldLineNumber', () => {
      const oldLineNumber = vm.$el.querySelector('.qa-old-diff-line-number').innerHTML;
      expect(parseInt(oldLineNumber, 10)).toBe(vm.oldLineNumber);
    });

    it('renders the oldLineContent', () => {
      const oldLineContent = vm.$el.querySelector('.line_content.old').innerHTML;
      expect(oldLineContent.includes(vm.oldLineContent)).toBe(true);
    });

    it('renders the contents of newLines', () => {
      const newLines = vm.$el.getElementsByClassName('line_holder new');

      expect([...newLines][0].innerHTML.includes(vm.newLines[0].content)).toBe(true);
      expect([...newLines][1].innerHTML.includes(vm.newLines[1].content)).toBe(true);
      expect([...newLines][2].innerHTML.includes(vm.newLines[2].content)).toBe(true);
    });

    it('renders a line number for each line', () => {
      const newLineNumbers = vm.$el.getElementsByClassName('qa-new-diff-line-number');

      expect([...newLineNumbers][0].innerHTML.includes(vm.newLines[0].lineNumber)).toBe(true);
      expect([...newLineNumbers][1].innerHTML.includes(vm.newLines[1].lineNumber)).toBe(true);
      expect([...newLineNumbers][2].innerHTML.includes(vm.newLines[2].lineNumber)).toBe(true);
    });
  });

  describe('applySuggestion', () => {
    it('emits apply event when applySuggestion is called', () => {
      const callback = () => {};

      spyOn(vm, '$emit');
      vm.applySuggestion(callback);

      expect(vm.$emit).toHaveBeenCalledWith('apply', vm.suggestion.id, callback);
    });

    it('does not emits apply event when `canApply` is set to false', () => {
      spyOn(vm, '$emit');
      vm.canApply = false;
      vm.applySuggestion();

      expect(vm.$emit).not.toHaveBeenCalled();
    });
  });
});
