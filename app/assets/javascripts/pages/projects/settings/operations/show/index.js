// Similar to app/assets/javascripts/pages/groups/edit/index.js
import $ from 'jquery';
import store from '~/error_tracking_settings/store';
import mountProjectDropdown from '~/error_tracking_settings';
import axios from '~/lib/utils/axios_utils';

document.addEventListener('DOMContentLoaded', () => {
  const listProjectsEl = document.getElementById('js-error-tracking-list-projects');
  const saveChangesEl = document.getElementById('js-error-tracking-save-changes');
  const dataEl = listProjectsEl;

  console.log('dataset', dataEl.dataset);

  const {
    dataset: { listProjectsEndpoint },
  } = dataEl;

  const {
    dataset: { errorTrackingSettingsUrl },
  } = saveChangesEl;

  console.log(saveChangesEl.dataset);

  mountProjectDropdown();

  // Code to test things locally. TODO: Remove when server implementation is ready.

  $(listProjectsEl).on('click', () => {
    store.dispatch('loadProjects', { listProjectsEndpoint });
  });

  $(saveChangesEl).on('click', event => {
    const shouldDo = true;

    // var bodyFormData = new FormData();
    // And then add the fields to the form you want to send :

    // bodyFormData.set('userName', 'Fred');
    // If you are uploading images, you may want to use .append

    // bodyFormData.append('image', imageFile);
    // And then you can use axios post method (You can amend it accordingly)

    // axios({
    //     method: 'post',
    //     url: 'myurl',
    //     data: bodyFormData,
    //     config: { headers: {'Content-Type': 'multipart/form-data' }}
    //     })
    //     .then(function (response) {
    //         //handle success
    //         console.log(response);
    //     })
    //     .catch(function (response) {
    //         //handle error
    //         console.log(response);
    //     });

    // {
    //   error_tracking_setting_attributes: {
    //     api_host: apiHost,
    //     token,
    //     enabled: true,
    //     project: {
    //       name: 'sentry-example',
    //       slug: 'sentry-example',
    //       organization_name: 'Sentry',
    //       organization_slug: 'sentry',
    //     },
    //   },
    // }

    if (shouldDo) {
      // Hack to grab form element data
      const apiHost = document.getElementById('js-error-tracking-api-url').value;
      const token = document.getElementById('js-error-tracking-token').value;

      event.preventDefault();
      const formData = new FormData();
      formData.set('commit', 'Save changes');
      formData.set('_method', 'patch');
      formData.set('utf8', '✓');
      formData.set('project[error_tracking_setting_attributes][api_host]', apiHost);
      formData.set('project[error_tracking_setting_attributes][token]', token);
      formData.set('project[error_tracking_setting_attributes][enabled]', true);
      formData.set('project[error_tracking_setting_attributes][project][name]', 'sentry-example');
      formData.set('project[error_tracking_setting_attributes][project][slug]', 'sentry-example');
      formData.set(
        'project[error_tracking_setting_attributes][project][organization_name]',
        'Sentry',
      );
      formData.set(
        'project[error_tracking_setting_attributes][project][organization_slug]',
        'sentry',
      );

      axios
        .post(errorTrackingSettingsUrl, formData, {
          headers: { 'Content-Type': 'multipart/form-data', Accept: 'text/html' },
          responseType: 'document',
        })
        .then(res => {
          console.log(res);
          // $('body').html(res.data);
          document.documentElement.innerHTML = res.data.documentElement.innerHTML;
        })
        .catch(() => {
          // do nothing
        });
    }
  });
});
