import Vue from 'vue';
import suggestionDiffHeaderComponent from '~/vue_shared/components/markdown/suggestion_diff_header.vue';

const MOCK_DATA = {
  canApply: true,
};

describe('Suggestion Diff component', () => {
  let vm;

  beforeEach(done => {
    const Component = Vue.extend(suggestionDiffHeaderComponent);

    vm = new Component({
      propsData: MOCK_DATA,
    }).$mount();

    Vue.nextTick(done);
  });

  describe('init', () => {
    it('renders a suggestion header', () => {
      const header = vm.$el.querySelector('.qa-suggestion-diff-header');

      expect(header).not.toBeNull();
      expect(header.innerHTML.includes('Suggested change')).toBe(true);
    });

    it('renders the correct icon in the suggestion header', () => {
      const header = vm.$el.querySelector('.qa-suggestion-diff-header');
      const icon = header.querySelector('svg use');

      expect(icon.getAttribute('xlink:href')).toContain('#question-o');
    });

    it('renders an apply button', () => {
      const applyBtn = vm.$el.querySelector('.qa-apply-btn');

      expect(applyBtn).not.toBeNull();
      expect(applyBtn.innerHTML.includes('Apply suggestion')).toBe(true);
    });

    it('does not render an apply button if `canApply` is set to false', () => {
      vm.canApply = false;

      Vue.nextTick(() => {
        expect(vm.$el.querySelector('.qa-apply-btn')).toBeNull();
      });
    });
  });

  describe('applySuggestion', () => {
    it('emits when the apply button is clicked', () => {
      spyOn(vm, '$emit');
      vm.applySuggestion();
      expect(vm.$emit).toHaveBeenCalled();
    });

    it('does not emit when the canApply is set to false', () => {
      spyOn(vm, '$emit');
      vm.canApply = false;
      vm.applySuggestion();
      expect(vm.$emit).not.toHaveBeenCalled();
    });
  });

  describe('suggestionApplied', () => {
    it('does not render apply button once a suggestion has been successfully applied', () => {
      vm.suggestionApplied(true);

      Vue.nextTick(() => {
        expect(vm.$el.querySelector('.qa-apply-btn')).toBeNull();
      });
    });

    it('renders apply button if a suggestion was not successfully applied', () => {
      vm.isApplied = true;
      vm.suggestionApplied(false);

      Vue.nextTick(() => {
        expect(vm.$el.querySelector('.qa-apply-btn')).not.toBeNull();
      });
    });
  });
});
