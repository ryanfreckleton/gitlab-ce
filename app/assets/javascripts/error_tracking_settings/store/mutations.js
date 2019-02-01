import types from './mutation_types';

export default {
  [types.RECEIVE_PROJECTS](state, projects) {
    Object.assign(state, {
      // TODO: Any project ordering required for consistency? Alphabetical?
      projects,
    });
  },
  [types.UPDATE_API_HOST](state, apiHost) {
    Object.assign(state, {
      apiHost,
    });
  },
  [types.UPDATE_ENABLED](state, enabled) {
    Object.assign(state, {
      enabled,
    });
  },
  [types.UPDATE_TOKEN](state, token) {
    Object.assign(state, {
      token,
    });
  },
  [types.UPDATE_CONNECT_SUCCESSFUL](state, connectSuccessful) {
    Object.assign(state, {
      connectSuccessful,
    });
  },
  [types.UPDATE_CONNECT_ERROR](state, connectError) {
    Object.assign(state, {
      connectError,
    });
  },
};
