<script>
import ProjectDropdown from './project_dropdown.vue';
import ErrorTrackingForm from './error_tracking_form.vue';

export default {
  name: 'Dropdown',
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
  },
  methods: {
    handleSubmit() {
      console.log(this.$store.state);
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
