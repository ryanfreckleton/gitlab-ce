import $ from 'jquery';
import store from '~/error_tracking_settings/store';
import mountErrorTrackingForm from '~/error_tracking_settings';

document.addEventListener('DOMContentLoaded', () => {
  const listProjectsEl = document.getElementById('js-error-tracking-list-projects');
  const dataEl = listProjectsEl;

  const { listProjectsEndpoint } = dataEl.dataset;

  mountErrorTrackingForm();

  $(listProjectsEl).on('click', () => {
    store.dispatch('loadProjects', { listProjectsEndpoint });
  });
});
