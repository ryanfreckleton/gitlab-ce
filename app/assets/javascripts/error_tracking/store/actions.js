import Service from '../services';
import * as types from './mutation_types';
import createFlash from '~/flash';
import { __ } from '~/locale';

export function getErrorList({ commit }, url) {
  Service.getErrorList(url)
    .then(( { data }) => {
      commit(types.SET_ERRORS, data.errors);
      commit(types.SET_EXTERNAL_URL, data.external_url);
      commit(types.SET_LOADING, false);
    })
    .catch(() => {
      commit(types.SET_LOADING, false);
      createFlash(__('Failed to load errors from Sentry'))
    });
}

export default () => {};
