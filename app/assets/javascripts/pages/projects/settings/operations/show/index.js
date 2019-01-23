// Similar to app/assets/javascripts/pages/groups/edit/index.js
import store from './store';
import mountProjectDropdown from '~/pages/projects/settings/operations/show/mount_project_dropdown';

document.addEventListener('DOMContentLoaded', () => {
  mountProjectDropdown();

  // Code to test things locally. TODO: Remove when server implementation is ready.
  store.dispatch('loadProjects', {});
});
