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
  computed: {
    placeholderText() {
      return s__('Error Tracking|Select Project');
    },
  },
};
</script>

<template>
  <!--
  .dropdown#vue-dropdown-placeholder
    %button.dropdown-menu-toggle.js-dropdown-toggle{ type: 'button', disabled: true }
      %span.dropdown-toggle-text
        = _('Select project')
        = icon('chevron-down')
  -->
  <!-- <div class="dropdown">
    <button class="dropdown-menu-toggle js-dropdown-toggle" type="button">
      <span class="dropdown-toggle-text">
        {{ placeholderText }}
        <icon :aria-label="__('Error Tracking|Select Project')" name="chevron-down"/>
      </span>
    </button>
  </div>-->
  <gl-dropdown class="w-100" menu-class="w-100 mw-100" toggle-class="w-100" :text="placeholderText">
    <!-- TODO: make the caret move to the right. could do so like this: -->
    <template slot="button-content">
      <span class="w-100">{{ placeholderText }}</span>
      <icon
        :aria-label="__('Error Tracking|Select Project')"
        name="chevron-down"
        style="right: 0px"
        css-classes="top"
      />
    </template>

    <gl-dropdown-item class="w-100">First item</gl-dropdown-item>
  </gl-dropdown>
</template>
