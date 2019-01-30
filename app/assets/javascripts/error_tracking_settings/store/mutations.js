import types from './mutation_types';

export default {
  [types.RECEIVE_PROJECTS](state, projects) {
    Object.assign(state, {
      // TODO: Any project ordering required for consistency? Alphabetical?
      projects,
    });
  },
};
