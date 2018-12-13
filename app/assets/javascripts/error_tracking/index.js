import Vue from 'vue';
import store from './store'
import ErrorTrackingList from './components/error_tracking_list.vue';

export default () =>
  new Vue({
    el: '#js-error_tracking',
    components: {
      ErrorTrackingList,
    },
    store,
    render(createElement) {
      const {
        indexPath,
        enableErrorTrackingLink
      } = document.querySelector(this.$options.el).dataset;

      return createElement('error-tracking-list', {
        props: {
          indexPath,
          enableErrorTrackingLink,
        },
      });
    },
  });
