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
  loadProjects({ commit, dispatch, state }, data) {
    return axios
      .post(`${data.listProjectsEndpoint}.json`, {
        error_tracking_setting: {
          api_host: state.apiHost,
          token: state.token,
        },
      })
      .then(res => {
        dispatch('receiveLoadProjects', res.data.projects.map(transformBackendProject));
        commit(types.UPDATE_CONNECT_SUCCESSFUL, true);
      })
      .catch(err => {
        commit(types.UPDATE_CONNECT_SUCCESSFUL, false);
        // TODO: error handling
        console.log(err);
      });
  },
  receiveLoadProjects({ commit }, projects) {
    commit(types.RECEIVE_PROJECTS, projects);
  },
  // TODO: Add mutations
  saveSettings({ state }, data) {
    console.log(data.operationsSettingsEndpoint);
    return axios
      .patch(data.operationsSettingsEndpoint, {
        project: {
          error_tracking_setting_attributes: {
            api_host: state.apiHost,
            enabled: state.enabled,
            token: state.token,
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
        // TODO: Show save success banner
        console.log('Saved successfully: ', res.data);
      })
      .catch(err => {
        // TODO: error handling
        console.log(err);
      });
  },
  updateApiHost({ commit }, apiHost) {
    commit(types.UPDATE_API_HOST, apiHost);
    commit(types.UPDATE_CONNECT_SUCCESSFUL, false);
  },
  updateToken({ commit }, token) {
    commit(types.UPDATE_TOKEN, token);
    commit(types.UPDATE_CONNECT_SUCCESSFUL, false);
  },
};
