import $ from 'jquery';
import Vue from 'vue';
import store from './store';
import ErrorTrackingSettings from './components/error_tracking_settings.vue';

export default () => {
  // TODO: make all dom searches relative to this element to save cycles
  const formContainerEl = $('.js-error-tracking-form').first();
  const containerEl = document.getElementById('vue-dropdown-placeholder');
  const listProjectsEl = document.getElementById('js-error-tracking-list-projects');

  const { listProjectsEndpoint } = listProjectsEl.dataset;

  console.log(formContainerEl.data());

  return new Vue({
    el: containerEl,
    store,
    components: {
      ErrorTrackingSettings,
    },
    data() {
      const {
        dataset: { slug, name, organizationName, organizationSlug },
      } = containerEl;
      const { apiHost, token } = formContainerEl.data();

      if (slug !== undefined) {
        return {
          initialToken: token,
          initialApiHost: apiHost,
          initialProject: {
            id: slug + organizationSlug,
            slug,
            name,
            organizationName,
            organizationSlug,
          },
        };
      }
      return { initialProject: null };
    },
    render(createElement) {
      return createElement(ErrorTrackingSettings, {
        props: {
          initialProject: this.initialProject,
          listProjectsEndpoint,
        },
      });
    },
  });
};
