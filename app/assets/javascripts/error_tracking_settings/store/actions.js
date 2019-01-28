import axios from '~/lib/utils/axios_utils';
import types from './mutation_types';

// TODO: If the only purpose is to strip out certain properties, use an existing library like underscore
const transformBackendProject = project => ({
  id: project.id,
  name: project.name,
});

export default {
  loadProjects({ dispatch }, data) {
    console.log('data', data);
    // TODO: Remove this when backend is hooked up

    // return axios.post(
    //   `http://localhost:3000/h5bp/html5-boilerplate/list_projects.json`,
    //   {
    //     error_tracking_setting: {
    //       api_host: '<url here>',
    //       token: '<token here>',
    //     },
    //   },
    //   {
    //     headers: { Accept: 'application/json, text/plain, */*' },
    //   },
    // );

    return axios
      .post(
        `${data.listProjectsEndpoint}.json`,
        {
          error_tracking_setting: {
            api_host: '<url here>',
            token: '<token here>',
          },
        },
        {
          headers: { Accept: 'application/json, text/plain, */*' },
        },
      )
      .then(res => {
        console.log('status', res.status);
        console.log('data', res.data);
        dispatch('receiveLoadProjects', res.data.map(transformBackendProject));
      });

    // if (true) {
    //   return dispatch('receiveLoadProjects', [
    //     { id: '10', name: 'Hello' },
    //     { id: '11', name: 'Hi there' },
    //     { id: '12', name: "I'm a project" },
    //   ]);
    // }

    // if (true) {
    //   return dispatch('receiveLoadProjects', []);
    // }

    // const endpoint = data.apiEndpoitUrl;
    // return axios.get(endpoint).then(res => {
    //   dispatch('receiveLoadProjects', res.data.map(transformBackendProject));
    // });
  },
  receiveLoadProjects({ commit }, projects) {
    commit(types.RECEIVE_PROJECTS, projects);
  },
};
