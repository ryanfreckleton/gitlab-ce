import axios from '~/lib/utils/axios_utils';
import types from './mutation_types';

const transformBackendProject = ({
  slug,
  name,
  organization_name: organizationName,
  organization_slug: organizationSlug,
}) => ({
  id: slug + organizationSlug,
  slug,
  name,
  organizationName,
  organizationSlug,
});

export default {
  loadProjects({ dispatch }, data) {
    return axios
      .post(`${data.listProjectsEndpoint}.json`, {
        error_tracking_setting: {
          api_host: data.apiHost,
          token: data.token,
        },
      })
      .then(res => {
        dispatch('receiveLoadProjects', res.data.projects.map(transformBackendProject));
      })
      .catch(err => {
        // TODO: error handling
        console.log(err);
      });
  },
  receiveLoadProjects({ commit }, projects) {
    commit(types.RECEIVE_PROJECTS, projects);
  },
  // TODO: Add mutations
  saveSettings(store, data) {
    console.log(data.operationsSettingsEndpoint);
    return axios
      .patch(data.operationsSettingsEndpoint, {
        project: {
          error_tracking_setting_attributes: {
            enabled: true,
            // TODO: Fix this
            api_host: 'http://35.228.54.90:9000/',
            token: data.token,
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
        console.log('Saved successfully: ', res.data);
      })
      .catch(err => {
        // TODO: error handling
        console.log(err);
      });
  },
};
