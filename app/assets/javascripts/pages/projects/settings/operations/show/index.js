// Similar to app/assets/javascripts/pages/groups/edit/index.js
import $ from 'jquery';
import store from '~/error_tracking_settings/store';
import mountProjectDropdown from '~/error_tracking_settings';

document.addEventListener('DOMContentLoaded', () => {
  const connectEl = document.getElementById('js-error-tracking-connect');

  mountProjectDropdown();

  // Code to test things locally. TODO: Remove when server implementation is ready.

  $(connectEl).on('click', () => {
    store.dispatch('loadProjects', {});
  });
});
