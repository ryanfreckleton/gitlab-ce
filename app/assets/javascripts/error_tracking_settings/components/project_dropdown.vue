<script>
// Similar to app/assets/javascripts/badges/components/badge.vue

import { s__ } from '~/locale';
import Icon from '~/vue_shared/components/icon.vue';

import {
  // GlLoadingIcon,
  // GlSearchBox,
  GlDropdown,
  // GlDropdownDivider,
  GlDropdownHeader,
  GlDropdownItem,
} from '@gitlab/ui';

export default {
  name: 'Dropdown',
  components: {
    GlDropdown,
    GlDropdownHeader,
    GlDropdownItem,
    Icon,
  },
  props: {
    initialProject: {
      type: Object,
      required: false,
      default: null,
    },
  },
  data() {
    return {
      selected: '',
    };
  },
  computed: {
    // TODO: tidy up this logic
    dropdownText() {
      if (this.selected === '' && this.initialProject) {
        return this.initialProject.name;
      }
      if (this.selected === '' && !this.initialProject) {
        return s__('Error Tracking|Select Project');
      }
      return this.$store.state.projects.find(item => item.id === this.selected).name;
    },
    errorText() {
      // TODO: read up on best way to handle translations with interpolation in JS
      return s__(
        `Error Tracking|Project ${
          this.initialProject.name
        } is no longer available. Select another project to continue.`,
      );
    },
    helperText() {
      return s__('Error Tracking|To enable project selection, enter a valid Auth Token');
    },
    isProjectListEmpty() {
      return this.areProjectsLoaded && this.$store.state.projects.length === 0;
    },
    isValid() {
      return this.isSelectedProjectInvalid || this.isProjectListEmpty;
    },
    isSelectedProjectInvalid() {
      // TODO: Disable saving the page when component is invalid
      return (
        this.selected !== '' &&
        this.areProjectsLoaded &&
        this.$store.state.projects.findIndex(item => item.id === this.selected) === -1
      );
    },
    areProjectsLoaded() {
      return this.$store.state.projects !== null;
    },
  },
  // TODO: Disable dropdown when projects haven't been loaded
  methods: {
    // TODO: Is there a better way to do this? v-model doesn't seem to bind directly to gl-dropdown because it's not a typical select element,
    // but it feels like there should be a better solution.
    // Perhaps some way to get this to work https://vuejs.org/v2/guide/forms.html#v-model-with-Components?
    handleClick(event) {
      this.selected = event.target.value;
      // TODO: Ensure that initial values are also preserved
      document.getElementById('project_error_tracking_setting_attributes_project').value =
        event.target.value;
    },
  },
};
</script>

<template>
  <div :class="[isSelectedProjectInvalid ? 'gl-show-field-errors' : '']">
    <!-- Following: HTML-only boostrap dropdown menu, for comparison -->
    <!-- <div class="dropdown">
      <button class="dropdown-menu-toggle js-dropdown-toggle w-100" type="button">
        <span class="dropdown-toggle-text">
          {{ dropdownText }}
          <icon :aria-label="__('Error Tracking|Select Project')" name="chevron-down"/>
        </span>
      </button>
    </div>-->
    <!--
      Note: dropdown-menu-toggle class is required to push the toggle to the right of the dropdown.
      Could fix this in the gitlab-ui component, or in css
    -->
    <!--
      Given how many classes are required here, could add a full-width option to gl-dropdown
    -->
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
      >{{ project.name }}</gl-dropdown-item>
    </gl-dropdown>
    <!-- TODO: Figure out the correct markup for an error message. Move the error state into gitlab-ui component if it's useful. -->
    <span v-if="isSelectedProjectInvalid" class="gl-field-error-message">{{errorText}}</span>
    <span v-if="!areProjectsLoaded">{{helperText}}</span>
  </div>
</template>
