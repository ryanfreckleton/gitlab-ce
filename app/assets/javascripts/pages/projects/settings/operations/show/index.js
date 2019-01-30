import $ from 'jquery';
import store from '~/error_tracking_settings/store';
import mountProjectDropdown from '~/error_tracking_settings';
import axios from '~/lib/utils/axios_utils';

document.addEventListener('DOMContentLoaded', () => {
  const listProjectsEl = document.getElementById('js-error-tracking-list-projects');
  const errorTrackingFormEl = $('.js-error-tracking-form').first();
  const dataEl = listProjectsEl;

  const errorTrackingFormUrl = errorTrackingFormEl.attr('action');
  const { listProjectsEndpoint } = dataEl.dataset;

  mountProjectDropdown();

  $(listProjectsEl).on('click', () => {
    store.dispatch('loadProjects', { listProjectsEndpoint });
  });

  $(errorTrackingFormEl).on('submit', event => {
    event.preventDefault();
    // Hack to grab form element data
    const apiHost = document.getElementById('js-error-tracking-api-url').value;
    const token = document.getElementById('js-error-tracking-token').value;

    axios
      .patch(errorTrackingFormUrl, {
        project: {
          error_tracking_setting_attributes: {
            api_host: apiHost,
            token,
            enabled: true,
            project: {
              name: 'sentry-example',
              slug: 'sentry-example',
              organization_name: 'Sentry',
              organization_slug: 'sentry',
            },
          },
        },
      })
      .then(res => {
        console.log('response:', res);
      })
      .catch(err => {
        console.error(err);
        // do nothing
      });
  });
});
