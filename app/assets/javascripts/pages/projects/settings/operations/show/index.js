// Similar to app/assets/javascripts/pages/groups/edit/index.js
import $ from 'jquery';
import store from '~/error_tracking_settings/store';
import mountProjectDropdown from '~/error_tracking_settings';

document.addEventListener('DOMContentLoaded', () => {
  const listProjectsEl = document.getElementById('js-error-tracking-list-projects');
  const dataEl = listProjectsEl;

  console.log('dataset', dataEl.dataset);

  const {
    dataset: { listProjectsEndpoint },
  } = dataEl;

  mountProjectDropdown();

  // Code to test things locally. TODO: Remove when server implementation is ready.

  $(listProjectsEl).on('click', () => {
    store.dispatch('loadProjects', { listProjectsEndpoint });
  });
});
