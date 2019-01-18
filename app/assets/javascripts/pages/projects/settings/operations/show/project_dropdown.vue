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
  data: () => ({
    list: [
      { key: 0, value: 'GitLab.com Frontend' },
      { key: 1, value: 'GitLab.com Backend' },
      { key: 2, value: 'Gitaly' },
      { key: 4, value: 'Omnibus' },
    ],
  }),
  computed: {
    placeholderText() {
      return s__('Error Tracking|Select Project');
    },
  },
  methods: {
    doThing: event => {
      console.log(event);
      alert('you clicked a thing');
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
    <!-- <template slot="button-content">
      <span class="w-100">{{ placeholderText }}</span>
      <icon
        :aria-label="__('Error Tracking|Select Project')"
        name="chevron-down"
        css-classes="right"
      />
    </template>-->
    <gl-dropdown-item
      v-for="item in list"
      :key="item.key"
      class="w-100"
      @click="doThing"
    >{{ item.value }}</gl-dropdown-item>
  </gl-dropdown>
</template>
