// Similar to app/assets/javascripts/pages/shared/mount_badge_settings.js
import Vue from 'vue';
import store from './store';
import ProjectDropdown from './components/project_dropdown.vue';

export default () => {
  const containerEl = document.getElementById('vue-dropdown-placeholder');
  const dataEl = containerEl; // TODO: can dataEl be the same as containerEl? test and change accordingly

  return new Vue({
    el: containerEl,
    store,
    components: {
      ProjectDropdown,
    },
    data() {
      const {
        dataset: { projectId, projectName },
      } = dataEl;
      return {
        project: {
          id: projectId,
          name: projectName,
        },
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
