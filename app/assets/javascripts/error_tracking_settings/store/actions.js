import axios from '~/lib/utils/axios_utils';
import types from './mutation_types';

// TODO: If the only purpose is to strip out certain properties, use an existing library like underscore
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
    // Hack to grab form element data
    const apiHost = document.getElementById('js-error-tracking-api-url').value;
    const token = document.getElementById('js-error-tracking-token').value;

    return axios
      .post(
        `${data.listProjectsEndpoint}.json`,
        {
          error_tracking_setting: {
            api_host: apiHost,
            token,
          },
        },
        {
          headers: {
            Accept: 'application/json, text/plain, */*',
            'Content-Type': 'application/json',
          },
        },
      )
      .then(res => {
        console.log(res.data.projects[0]);
        dispatch('receiveLoadProjects', res.data.projects.map(transformBackendProject));
      })
      .catch(err => {
        console.log(err);
      });
  },
  receiveLoadProjects({ commit }, projects) {
    commit(types.RECEIVE_PROJECTS, projects);
  },
};
