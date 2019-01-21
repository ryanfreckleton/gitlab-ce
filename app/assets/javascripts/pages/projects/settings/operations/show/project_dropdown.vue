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
      return this.selected !== ''
        ? this.list.find(item => item.id === this.selected).value
        : s__('Error Tracking|Select Project');
    },
  },
  methods: {
    // TODO: Is there a better way to do this? v-model doesn't seem to bind directly to gl-dropdown because it's not a typical select element,
    // but it feels like there should be a better solution.
    // Perhaps some way to get this to work https://vuejs.org/v2/guide/forms.html#v-model-with-Components?
    handleClick(event) {
      this.selected = event.target.value;
      document.getElementById('project_error_tracking_setting_attributes_project').value =
        event.target.value;
    },
  },
};
</script>

<template>
  <!-- TODO: Remove this div -->
  <div>
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
      class="w-100"
      menu-class="w-100 mw-100"
      toggle-class="dropdown-menu-toggle w-100"
      :text="buttonText"
    >
      <!-- TODO: make the caret move to the right. could do so like this: -->
      <!-- <template slot="button-content">
        <span class="dropdown-toggle-text w-100">
          {{ buttonText }}
          <icon
            :aria-label="__('Error Tracking|Select Project')"
            name="chevron-down"
            css-classes="right"
          />
        </span>
      </template>-->
      <!-- <gl-dropdown-item disabled value class="disabled w-100">Select Project</gl-dropdown-item> -->
      <gl-dropdown-item
        v-for="item in list"
        :key="item.id"
        :value="item.id"
        class="w-100"
        @click="handleClick"
      >{{ item.value }}</gl-dropdown-item>
    </gl-dropdown>
  </div>
</template>
