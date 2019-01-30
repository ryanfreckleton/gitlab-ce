import Vue from 'vue';
import store from './store';
import ProjectDropdown from './components/project_dropdown.vue';

export default () => {
  const containerEl = document.getElementById('vue-dropdown-placeholder');

  return new Vue({
    el: containerEl,
    store,
    components: {
      ProjectDropdown,
    },
    data() {
      const {
        dataset: { slug, name, organizationName, organizationSlug },
      } = containerEl;
      if (slug !== undefined) {
        return {
          project: {
            id: slug + organizationSlug,
            slug,
            name,
            organizationName,
            organizationSlug,
          },
        };
      }
      return { projects: null };
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
