import * as types from './mutation_types';

export default {
  [types.ADD_ERRORS](state, data) {
    state.errors = data;
  },
  [types.SET_LOADING](state, loading) {
    state.loadingErrors = loading;
  },
};
