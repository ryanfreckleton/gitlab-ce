import Service from '../services';
import * as types from './mutation_types';

export function getErrorList({ commit }, url) {
  Service.getErrorList(url)
    .then(( { data }) => {
      commit(types.ADD_ERRORS, data);
      commit(types.SET_LOADING, false);
    });
}

export default () => {};
