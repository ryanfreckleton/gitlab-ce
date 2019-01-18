// Similar to app/assets/javascripts/pages/shared/mount_badge_settings.js
// TODO: move me

import Vue from 'vue';
import ProjectDropdown from '~/pages/projects/settings/operations/show/project_dropdown.vue';

export default () => {
  const projectDropdownElement = document.getElementById('vue-dropdown-placeholder');

  return new Vue({
    el: projectDropdownElement,
    // store, // TODO: remove if unnecessary
    components: {
      ProjectDropdown,
    },
    render(createElement) {
      return createElement(ProjectDropdown);
    },
  });
};
