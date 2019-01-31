<script>
import { s__ } from '~/locale';
import { mapActions } from 'vuex';
import Icon from '~/vue_shared/components/icon.vue';

import { GlFormGroup, GlFormInput } from '@gitlab/ui';

export default {
  name: 'ErrorTrackingForm',
  components: { GlFormGroup, GlFormInput, Icon },
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
      // this.apiHost = 'test';
      this.loadProjects({
        listProjectsEndpoint: this.listProjectsEndpoint,
        enabled: this.enabled,
        apiHost: this.apiHost,
        token: this.token,
      });
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
    <gl-form-group
      :label="s__('Sentry API URL')"
      label-class="label-bold"
      label-for="project_error_tracking_setting_attributes_host_url"
    >
      <gl-form-input
        id="project_error_tracking_setting_attributes_host_url"
        v-model="apiHost"
        :placeholder="s__('https://mysentryserver.com')"
      />
      <p class="form-text text-muted">{{ urlDescription }}</p>
    </gl-form-group>
    <gl-form-group
      :label="s__('Auth Token')"
      label-class="label-bold"
      label-for="project_error_tracking_setting_attributes_token"
    >
      <gl-form-input
        id="project_error_tracking_setting_attributes_token"
        v-model="token"
        class="form-control form-control-inline"
        style="width: auto;"
      />
      <div class="btn btn-success prepend-left-10" @click="handleClick">{{ connectText }}</div>
      <p class="form-text text-muted">{{ tokenDescription }}</p>
    </gl-form-group>
  </div>
</template>
