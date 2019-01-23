<script>
// Similar to app/assets/javascripts/badges/components/badge.vue
// TODO: Move Me

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
      list: [
        { id: '0', value: 'GitLab.com Frontend' },
        { id: '1', value: 'GitLab.com Backend' },
        { id: '2', value: 'Gitaly' },
        { id: '4', value: 'Omnibus' },
      ],
      selected: '',
    };
  },
  computed: {
    buttonText() {
      if (this.selected === '' && this.initialProject) {
        return this.initialProject.name;
      }

      if (this.selected === '' && !this.initialProject) {
        return s__('Error Tracking|Select Project');
      }

      return this.list.find(item => item.id === this.selected).value;
    },
    disabled() {
      return this.list.length === 0;
    },
    errorText() {
      // TODO: read up on best way to handle translations with interpolation in JS
      if (!this.valid) {
        return s__(
          `Error Tracking|Project ${
            this.initialProject.name
          } is no longer available. Select another project to continue.`,
        );
      }
      return '';
    },
    valid() {
      // TODO: handle the initial case
      // TODO: Disable saving the page when component is invalid
      return this.list.findIndex(item => item.id === this.selected) > -1;
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
  <div :class="[valid ? '' : 'gl-show-field-errors']">
    <!-- Following: HTML-only boostrap dropdown menu, for comparison -->
    <!-- <div class="dropdown">
      <button class="dropdown-menu-toggle js-dropdown-toggle w-100" type="button">
        <span class="dropdown-toggle-text">
          {{ buttonText }}
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
      :disabled="disabled"
      menu-class="w-100 mw-100"
      toggle-class="dropdown-menu-toggle w-100 gl-field-error-outline"
      :text="buttonText"
    >
      <gl-dropdown-item
        v-for="item in list"
        :key="item.id"
        :value="item.id"
        class="w-100"
        @click="handleClick"
      >{{ item.value }}</gl-dropdown-item>
    </gl-dropdown>
    <!-- TODO: Figure out the correct markup for an error message. Move the error state into gitlab-ui component if it's useful. -->
    <span class="gl-field-error-message">{{errorText}}</span>
  </div>
</template>
