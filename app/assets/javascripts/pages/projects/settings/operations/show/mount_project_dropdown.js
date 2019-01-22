// Similar to app/assets/javascripts/pages/shared/mount_badge_settings.js
// TODO: move me

import Vue from 'vue';
import ProjectDropdown from '~/pages/projects/settings/operations/show/project_dropdown.vue';

export default () => {
  const containerEl = document.getElementById('vue-dropdown-placeholder');
  const dataEl = containerEl; // TODO: can dataEl be the same as containerEl? test and change accordingly

  return new Vue({
    el: containerEl,
    // store, // TODO: remove if unnecessary
    components: {
      ProjectDropdown,
    },
    data() {
      const {
        dataset: { project },
      } = dataEl;
      return {
        project,
      };
    },
    render(createElement) {
      return createElement(ProjectDropdown, {
        props: {
          initialProject: this.project,
        },
      });
    },
  });
};
