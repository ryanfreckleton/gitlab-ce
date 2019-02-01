import axios from '~/lib/utils/axios_utils';
import types from './mutation_types';
import createFlash from '~/flash';
import { s__ } from '~/locale';

export const transformBackendProject = ({
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

const transformFrontendProject = project => ({
  slug: project.slug,
  name: project.slug,
  organization_name: project.organizationName,
  organization_slug: project.organizationSlug,
});

// TODO: determine action naming conventions
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
  saveSettings({ state }, data) {
    return axios
      .patch(data.operationsSettingsEndpoint, {
        project: {
          error_tracking_setting_attributes: {
            api_host: state.apiHost,
            enabled: state.enabled,
            token: state.token,
            project: state.selectedProject ? transformFrontendProject(state.selectedProject) : null,
          },
        },
      })
      .then(() => {
        createFlash(s__('Your changes have been saved.'), 'notice');
      })
      .catch(err => {
        createFlash(
          `${s__('There was an error saving your changes.')} ${err.message ? err.message : ''}`,
          'alert',
        );
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
  updateSelectedProject({ commit }, selectedProject) {
    commit(types.UPDATE_SELECTED_PROJECT, selectedProject);
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
