<script>
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

// Similar to app/assets/javascripts/badges/components/badge.vue
// TODO: Move Me

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
  <gl-dropdown :text="placeholderText">
    <gl-dropdown-item>First item</gl-dropdown-item>
  </gl-dropdown>
</template>
