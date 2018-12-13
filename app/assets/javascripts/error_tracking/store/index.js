import Vue from 'vue';
import Vuex from 'vuex';
import * as actions from './actions';
import mutations from './mutations';

Vue.use(Vuex);

export const createStore = () => new Vuex.Store({
  state: {
    errors: [],
    loadingErrors: true,
  },
  actions,
  mutations,
});

export default createStore();
