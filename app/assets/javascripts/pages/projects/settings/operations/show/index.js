// Similar to app/assets/javascripts/pages/groups/edit/index.js
import store from '~/error_tracking_settings/store';
import mountProjectDropdown from '~/error_tracking_settings';

document.addEventListener('DOMContentLoaded', () => {
  mountProjectDropdown();

  // Code to test things locally. TODO: Remove when server implementation is ready.
  store.dispatch('loadProjects', {});
});
