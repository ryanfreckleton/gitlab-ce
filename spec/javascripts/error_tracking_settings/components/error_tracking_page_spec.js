import Vuex from 'vuex';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import ErrorTrackingSettings from '~/error_tracking_settings/components/error_tracking_settings.vue';
import ErrorTrackingForm from '~/error_tracking_settings/components/error_tracking_form.vue';
import ProjectDropdown from '~/error_tracking_settings/components/project_dropdown.vue';
import { createStore } from '~/error_tracking_settings/store';
import { TEST_HOST } from 'spec/test_constants';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('error tracking settings page', () => {
  let store;
  let wrapper;

  function mountComponent() {
    wrapper = shallowMount(ErrorTrackingSettings, {
      localVue,
      store,
      propsData: {
        listProjectsEndpoint: TEST_HOST,
        operationsSettingsEndpoint: TEST_HOST,
      },
    });
  }

  beforeEach(() => {
    store = createStore();

    mountComponent();
  });

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
    }
  });

  describe('section', () => {
    it('renders the form and dropdown', () => {
      expect(wrapper.find(ErrorTrackingForm).exists()).toBeTruthy();
      expect(wrapper.find(ProjectDropdown).exists()).toBeTruthy();
    });

    it('renders the Save Changes button', () => {
      expect(wrapper.find('[data-qa-id=error-tracking-button').exists()).toBeTruthy();
    });

    it('enables the button by default', () => {
      expect(wrapper.find('[data-qa-id=error-tracking-button').attributes('disabled')).toBeFalsy();
    });

    it('disables the button when saving', () => {
      store.state.settingsLoading = true;

      expect(wrapper.find('[data-qa-id=error-tracking-button').attributes('disabled')).toBeTruthy();
    });
  });
});
