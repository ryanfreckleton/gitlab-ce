import Vue from 'vue';
import ErrorTrackingList from './components/error_tracking_list.vue';

export default () =>
  new Vue({
    el: '#js-error_tracking',
    components: {
      ErrorTrackingList,
    },
    render(createElement) {
      return createElement('error-tracking-list', {
        props: {

        },
      });
    },
  });
