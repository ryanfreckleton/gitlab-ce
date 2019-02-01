import $ from 'jquery';
import Vue from 'vue';
import store from './store';
import ErrorTrackingSettings from './components/error_tracking_settings.vue';

export default () => {
  // TODO: make all dom searches relative to this element to save cycles
  const formContainerEl = $('.js-error-tracking-form').first();
  const containerEl = document.getElementById('vue-dropdown-placeholder');
  const listProjectsEl = document.getElementById('js-error-tracking-list-projects');

  const operationsSettingsEndpoint = formContainerEl.attr('action');
  const { listProjectsEndpoint } = listProjectsEl.dataset;

  console.log('data: ', formContainerEl.data());

  return new Vue({
    el: formContainerEl[0],
    store,
    components: {
      ErrorTrackingSettings,
    },
    data() {
      const {
        dataset: { slug, name, organizationName, organizationSlug },
      } = containerEl;
      const { apiHost, enabled, token } = formContainerEl.data();

      const data = {
        initialEnabled: enabled,
        initialToken: token,
        initialApiHost: apiHost,
      };

      if (slug !== undefined) {
        return {
          ...data,
          initialProject: {
            id: slug + organizationSlug,
            slug,
            name,
            organizationName,
            organizationSlug,
          },
        };
      }
      return { ...data, initialProject: null };
    },
    render(createElement) {
      return createElement(ErrorTrackingSettings, {
        props: {
          initialEnabled: this.initialEnabled,
          initialToken: this.initialToken,
          initialApiHost: this.initialApiHost,
          initialProject: this.initialProject,
          listProjectsEndpoint,
          operationsSettingsEndpoint,
        },
      });
    },
  });
};
