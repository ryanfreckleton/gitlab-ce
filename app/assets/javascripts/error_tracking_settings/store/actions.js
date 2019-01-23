import axios from '~/lib/utils/axios_utils';
import types from './mutation_types';

// TODO: If the only purpose is to strip out certain properties, use an existing library like underscore
const transformBackendProject = project => ({
  id: project.id,
  name: project.name,
});

export default {
  loadProjects({ dispatch }, data) {
    // TODO: Remove this when backend is hooked up
    if (true) {
      return dispatch('receiveLoadProjects', [
        { id: '10', name: 'Hello' },
        { id: '11', name: 'Hi there' },
        { id: '12', name: "I'm a project" },
      ]);
    }

    const endpoint = data.apiEndpoitUrl;
    return axios.get(endpoint).then(res => {
      dispatch('receiveLoadProjects', res.data.map(transformBackendProject));
    });
  },
  receiveLoadProjects({ commit }, projects) {
    commit(types.RECEIVE_PROJECTS, projects);
  },
};
