import * as types from './mutation_types';

export default {
  [types.ADD_ERRORS](state, data) {
    state.errors = data;
  },
};
