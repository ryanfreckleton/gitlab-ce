<script>
import { s__ } from '~/locale';
import { mapActions } from 'vuex';
import Icon from '~/vue_shared/components/icon.vue';

import { GlDropdown, GlDropdownHeader, GlDropdownItem } from '@gitlab/ui';

export default {
  name: 'ErrorSettingsProjectDropdown',
  components: {
    GlDropdown,
    GlDropdownHeader,
    GlDropdownItem,
    Icon,
  },
  data() {
    return {
      projectLabel: s__('Project'),
    };
  },
  computed: {
    selectedProject: {
      get() {
        return this.$store.state.selectedProject;
      },
      set(selectedProject) {
        this.updateSelectedProject(selectedProject);
      },
    },
    dropdownText() {
      if (this.selectedProject !== null) {
        return this.getDisplayName(this.selectedProject);
      }
      if (!this.areProjectsLoaded || this.isProjectListEmpty) {
        return s__('No projects available');
      }
      return s__('Select project');
    },
    errorText() {
      // TODO: read up on best way to handle translations with interpolation in JS
      return s__(
        `Error Tracking|Project ${
          this.initialProject.name
        } is no longer available. Select another project to continue.`,
      );
    },
    projectSelectionText() {
      if (this.$store.state.token) {
        return s__(
          "Error Tracking|Click 'Connect' to re-establish the connection to Sentry and activate the dropdown.",
        );
      }
      return s__('Error Tracking|To enable project selection, enter a valid Auth Token');
    },
    isProjectListEmpty() {
      return this.areProjectsLoaded && this.$store.state.projects.length === 0;
    },
    isProjectValid() {
      return (
        this.selectedProject &&
        this.areProjectsLoaded &&
        this.$store.state.projects.findIndex(item => item.id === this.selectedProject.id) === -1
      );
    },
    areProjectsLoaded() {
      return this.$store.state.projects !== null;
    },
  },
  methods: {
    ...mapActions(['updateSelectedProject']),
    // TODO: Is there a better way to do this? v-model doesn't seem to bind directly to gl-dropdown because it's not a typical select element,
    // but it feels like there should be a better solution.
    // Perhaps some way to get this to work https://vuejs.org/v2/guide/forms.html#v-model-with-Components?
    handleClick(event) {
      this.selectedProject = {
        ...this.$store.state.projects.find(item => item.id === event.target.value),
      };
    },
    getDisplayName(project) {
      return `${project.organizationName} | ${project.name}`;
    },
  },
};
</script>

<template>
  <div :class="[isProjectValid ? 'gl-show-field-errors' : '']">
    <!--
      Note: dropdown-menu-toggle class is required to push the toggle to the right of the dropdown.
      Could fix this in the gitlab-ui component, or in css
    -->
    <!--
      Given how many classes are required here, could add a full-width option to gl-dropdown
    -->
    <label class="label-bold" for="project_error_tracking_setting_attributes_project">{{
      projectLabel
    }}</label>
    <gl-dropdown
      id="project_error_tracking_setting_attributes_project"
      name="project[error_tracking_setting_attributes][project]"
      class="w-100"
      :disabled="!areProjectsLoaded || isProjectListEmpty"
      menu-class="w-100 mw-100"
      toggle-class="dropdown-menu-toggle w-100 gl-field-error-outline"
      :text="dropdownText"
    >
      <gl-dropdown-item
        v-for="project in $store.state.projects"
        :key="project.id"
        :value="project.id"
        class="w-100"
        @click="handleClick"
        >{{ getDisplayName(project) }}</gl-dropdown-item
      >
    </gl-dropdown>
    <!-- TODO: Figure out the correct markup for an error message. Move the error state into gitlab-ui component if it's useful. -->
    <!-- TODO: possibly convert to else-if? -->
    <span v-if="isProjectValid" class="form-text gl-field-error-message">{{ errorText }}</span>
    <span v-else-if="!areProjectsLoaded" class="form-text text-muted">{{
      projectSelectionText
    }}</span>
  </div>
</template>
