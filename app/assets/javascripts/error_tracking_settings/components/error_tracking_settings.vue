<script>
import { mapActions } from 'vuex';
import ProjectDropdown from './project_dropdown.vue';
import ErrorTrackingForm from './error_tracking_form.vue';

export default {
  name: 'ErrorTrackingSettings',
  components: { ProjectDropdown, ErrorTrackingForm },
  props: {
    // TODO: Can prop definitions be composed / passed through transparently?
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
    initialProject: {
      type: Object,
      required: false,
      default: null,
    },
    listProjectsEndpoint: {
      type: String,
      required: true,
    },
    operationsSettingsEndpoint: {
      type: String,
      required: true,
    },
  },
  methods: {
    ...mapActions(['saveSettings']),
    handleSubmit() {
      this.saveSettings({
        // TODO: Fix this
        token: this.initialToken,
        operationsSettingsEndpoint: this.operationsSettingsEndpoint,
      });
    },
  },
};
</script>

<template>
  <div>
    <ErrorTrackingForm
      :initial-api-host="initialApiHost"
      :initial-enabled="initialEnabled"
      :initial-token="initialToken"
      :list-projects-endpoint="listProjectsEndpoint"
    />
    <div class="form-group">
      <ProjectDropdown :initial-project="initialProject"/>
    </div>
    <input
      type="submit"
      name="commit"
      value="Save changes"
      class="btn btn-success"
      @click="handleSubmit"
    >
  </div>
</template>
