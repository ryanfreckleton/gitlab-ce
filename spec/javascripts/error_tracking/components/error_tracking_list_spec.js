import { createLocalVue, shallowMount } from '@vue/test-utils';
import Vuex from 'vuex';
import ErrorTrackingList from '~/error_tracking/components/error_tracking_list.vue';
import { GlButton, GlEmptyState, GlLoadingIcon, GlTable } from '@gitlab/ui';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('ErrorTrackingList', () => {
  let store;
  let wrapper;
  let originalGon = window.gon;

  function mountComponent() {
    wrapper = shallowMount(ErrorTrackingList, {
      localVue,
      store,
      propsData: {
        indexPath: '/path',
        enableErrorTrackingLink: '/link',
      },
    });
  }

  beforeEach(() => {
    const actions = {
      getErrorList: () => {},
    };

    const state = {
      errors: [],
      loadingErrors: true,
    };

    store = new Vuex.Store({
      actions,
      state,
    });

    window.gon = {
      features: {
        errorTracking: true,
      },
    };
  });

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
    }
    window.gon = originalGon;
  });

  describe('loading', () => {
    beforeEach(() => {
      mountComponent();
    });

    it('shows spinner', () => {
      expect(wrapper.find(GlLoadingIcon).exists()).toBeTruthy();
      expect(wrapper.find(GlTable).exists()).toBeFalsy();
      expect(wrapper.find(GlButton).exists()).toBeFalsy();
    });
  })

  describe('results', () => {
    beforeEach(() => {
      store.state.loadingErrors = false;

      mountComponent();
    });

    it('shows table', () => {
      expect(wrapper.find(GlLoadingIcon).exists()).toBeFalsy();
      expect(wrapper.find(GlTable).exists()).toBeTruthy();
      expect(wrapper.find(GlButton).exists()).toBeTruthy();
    });
  });

  describe('no results', () => {
    beforeEach(() => {
      store.state.loadingErrors = false;

      mountComponent();
    });

    it('shows empty table', () => {
      expect(wrapper.find(GlLoadingIcon).exists()).toBeFalsy();
      expect(wrapper.find(GlTable).exists()).toBeTruthy();
      expect(wrapper.find(GlButton).exists()).toBeTruthy();
    });
  });

  describe('error tracking feature disabled', () => {
    beforeEach(() => {
      window.gon.features.errorTracking = false;

      mountComponent();
    });

    it('shows empty state', () => {
      expect(wrapper.find(GlEmptyState).exists()).toBeTruthy();
      expect(wrapper.find(GlLoadingIcon).exists()).toBeFalsy();
      expect(wrapper.find(GlTable).exists()).toBeFalsy();
      expect(wrapper.find(GlButton).exists()).toBeFalsy();
    });
  });
});
