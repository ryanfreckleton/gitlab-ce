<script>
import ProjectDropdown from './project_dropdown.vue';
import ErrorTrackingForm from './error_tracking_form.vue';

export default {
  name: 'Dropdown',
  components: { ProjectDropdown, ErrorTrackingForm },
  props: {
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
};
</script>

<template>
  <div>
    <ErrorTrackingForm :list-projects-endpoint="listProjectsEndpoint"/>
    <ProjectDropdown :initial-project="initialProject"/>
  </div>
</template>
