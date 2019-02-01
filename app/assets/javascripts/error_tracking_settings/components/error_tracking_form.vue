<script>
import { s__ } from '~/locale';
import { mapActions } from 'vuex';
import Icon from '~/vue_shared/components/icon.vue';
import BFormInput from 'bootstrap-vue/es/components/form-input/form-input';

import { GlFormGroup, GlFormInput } from '@gitlab/ui';

export default {
  name: 'ErrorTrackingForm',
  components: { BFormInput, GlFormGroup, GlFormInput, Icon },
  props: {
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
      apiHost: this.initialApiHost,
      enabled: this.initialEnabled,
      token: this.initialToken,
    };
  },
  computed: {},
  methods: {
    ...mapActions(['loadProjects']),
    handleClick() {
      console.log(this.enabled, this.apiHost, this.token);
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
        <div class="btn btn-success prepend-left-10" @click="handleClick">{{ connectText }}</div>
        <p class="form-text text-muted">{{ tokenDescription }}</p>
      </div>
    </div>
  </div>
</template>
