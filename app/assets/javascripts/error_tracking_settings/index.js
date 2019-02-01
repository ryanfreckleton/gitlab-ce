import $ from 'jquery';
import Vue from 'vue';
import store from './store';
import types from './store/mutation_types';
import ErrorTrackingSettings from './components/error_tracking_settings.vue';

const getInitialProject = projectDataElement => {
  const { slug, name, organizationName, organizationSlug } = projectDataElement.data();
  if (slug) {
    return {
      slug,
      name,
      organizationName,
      organizationSlug,
    };
  }
  return null;
};

export default () => {
  // TODO: make all dom searches relative to this element to save cycles
  const formContainerEl = $('.js-error-tracking-form').first();
  const listProjectsEl = document.getElementById('js-error-tracking-list-projects');

  const operationsSettingsEndpoint = formContainerEl.attr('action');
  const { listProjectsEndpoint } = listProjectsEl.dataset;

  const { apiHost, enabled, token } = formContainerEl.data();
  const initialProject = getInitialProject(formContainerEl);

  // Set up initial data from DOM
  store.commit(types.UPDATE_API_HOST, apiHost);
  store.commit(types.UPDATE_ENABLED, enabled);
  store.commit(types.UPDATE_TOKEN, token);
  store.commit(types.UPDATE_SELECTED_PROJECT, initialProject);

  return new Vue({
    el: formContainerEl[0],
    store,
    components: {
      ErrorTrackingSettings,
    },
    data() {
      return {
        initialEnabled: enabled,
        initialToken: token,
        initialApiHost: apiHost,
      };
    },
    render(createElement) {
      return createElement(ErrorTrackingSettings, {
        props: {
          initialEnabled: this.initialEnabled,
          initialToken: this.initialToken,
          initialApiHost: this.initialApiHost,
          listProjectsEndpoint,
          operationsSettingsEndpoint,
        },
      });
    },
  });
};
