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
  loadProjects({ dispatch, state }, data) {
    return axios
      .post(`${data.listProjectsEndpoint}.json`, {
        error_tracking_setting: {
          api_host: state.apiHost,
          token: state.token,
        },
      })
      .then(res => {
        dispatch('receiveLoadProjects', res.data.projects.map(transformBackendProject));
        dispatch('connectSuccess');
      })
      .catch(() => {
        dispatch('connectFailed');
        dispatch('receiveLoadProjects', null);
      });
  },
  receiveLoadProjects({ commit }, projects) {
    commit(types.RECEIVE_PROJECTS, projects);
  },
  // TODO: Add mutations
  saveSettings({ state }, data) {
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
  updateApiHost({ commit, dispatch }, apiHost) {
    commit(types.UPDATE_API_HOST, apiHost);
    dispatch('connectReset');
  },
  updateToken({ commit, dispatch }, token) {
    commit(types.UPDATE_TOKEN, token);
    dispatch('connectReset');
  },
  connectFailed({ commit }) {
    commit(types.UPDATE_CONNECT_SUCCESSFUL, false);
    commit(types.UPDATE_CONNECT_ERROR, true);
  },
  connectReset({ commit }) {
    commit(types.UPDATE_CONNECT_SUCCESSFUL, false);
    commit(types.UPDATE_CONNECT_ERROR, false);
  },
  connectSuccess({ commit }) {
    commit(types.UPDATE_CONNECT_SUCCESSFUL, true);
    commit(types.UPDATE_CONNECT_ERROR, false);
  },
};
