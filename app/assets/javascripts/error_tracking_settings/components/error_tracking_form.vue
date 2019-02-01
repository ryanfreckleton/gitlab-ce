<script>
import { s__ } from '~/locale';
import { mapActions } from 'vuex';
import Icon from '~/vue_shared/components/icon.vue';
import types from '../store/mutation_types';

import { GlFormGroup, GlFormInput } from '@gitlab/ui';

export default {
  name: 'ErrorTrackingForm',
  components: { GlFormGroup, GlFormInput, Icon },
  props: {
    // TODO: Remove initial values if not required for error states
    initialApiHost: {
      type: String,
      required: true,
    },
    initialEnabled: {
      type: Boolean,
      required: true,
    },
    initialToken: {
      type: String,
      required: true,
    },
    listProjectsEndpoint: {
      type: String,
      required: true,
    },
  },
  data() {
    console.log(this.initialApiHost);
    return {
      connectText: s__('Connect'),
      enabledText: s__('Active'),
      tokenDescription: s__(
        "After adding your Auth Token, use the 'Connect' button to load projects",
      ),
      urlDescription: s__('Find your hostname in your Sentry account settings page'),
    };
  },
  computed: {
    showCheck() {
      // TODO
      return true;
    },
    // Two-way computed property pattern: https://vuex.vuejs.org/guide/forms.html#two-way-computed-property
    apiHost: {
      get() {
        return this.$store.state.apiHost;
      },
      set(value) {
        this.$store.commit(types.UPDATE_API_HOST, value);
      },
    },
    enabled: {
      get() {
        return this.$store.state.enabled;
      },
      set(value) {
        this.$store.commit(types.UPDATE_ENABLED, value);
      },
    },
    token: {
      get() {
        return this.$store.state.token;
      },
      set(value) {
        this.$store.commit(types.UPDATE_TOKEN, value);
      },
    },
  },
  methods: {
    ...mapActions(['loadProjects']),
    handleConnectClick() {
      this.loadProjects({
        listProjectsEndpoint: this.listProjectsEndpoint,
        apiHost: this.apiHost,
        token: this.token,
      });
    },
    mounted() {
      const inputElement = this.$refs.input.$el;
      inputElement.value = 'some value';
      inputElement.dispatchEvent(new Event('input'));
    },
  },
};
</script>

<template>
  <div>
    <div class="form-check form-group">
      <input
        id="project_error_tracking_setting_attributes_enabled"
        v-model="enabled"
        class="form-check-input"
        type="checkbox"
      >
      <label
        class="form-check-label"
        for="project_error_tracking_setting_attributes_enabled"
      >{{ enabledText }}</label>
    </div>
    <div class="form-group">
      <div>
        <label
          class="label-bold"
          for="project_error_tracking_setting_attributes_api_host"
        >{{s__('Sentry API URL')}}</label>
        <input
          id="project_error_tracking_setting_attributes_api_host"
          v-model="apiHost"
          class="form-control"
          :placeholder="s__('https://mysentryserver.com')"
        >
        <p class="form-text text-muted">{{ urlDescription }}</p>
      </div>
    </div>
    <div class="form-group">
      <div>
        <!-- TODO: remove inline styles -->
        <label
          class="label-bold"
          for="project_error_tracking_setting_attributes_token"
          style="display: block;"
        >{{s__('Auth Token')}}</label>
        <!-- TODO: Figure out how to make this wide enough -->
        <input
          id="project_error_tracking_setting_attributes_token"
          v-model="token"
          class="form-control form-control-inline"
          style="width: auto;"
        >
        <button class="btn btn-success prepend-left-5" @click="handleConnectClick">{{ connectText }}</button>
        <icon
          v-show="showCheck"
          class="prepend-left-5"
          :aria-label="__('Projects Successfully Retrieved')"
          name="check-circle"
        />
        <p class="form-text text-muted">{{ tokenDescription }}</p>
      </div>
    </div>
  </div>
</template>
