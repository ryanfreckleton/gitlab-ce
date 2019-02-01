<script>
import { s__ } from '~/locale';
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
    listProjectsEndpoint: {
      type: String,
      required: true,
    },
    operationsSettingsEndpoint: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      saveChangesText: s__('Save changes'),
    };
  },
  methods: {
    ...mapActions(['saveSettings']),
    handleSubmit() {
      this.saveSettings({
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
      <ProjectDropdown/>
    </div>
    <button class="btn btn-success" @click="handleSubmit">{{saveChangesText}}</button>
  </div>
</template>
