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
    doThing(event) {
      this.selected = event.target.value;
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
  <gl-dropdown
    v-model="selected"
    class="w-100"
    menu-class="w-100 mw-100"
    toggle-class="w-100"
    :text="buttonText"
  >
    <!-- TODO: make the caret move to the right. could do so like this: -->
    <!-- <template slot="button-content">
      <span class="w-100">{{ placeholderText }}</span>
      <icon
        :aria-label="__('Error Tracking|Select Project')"
        name="chevron-down"
        css-classes="right"
      />
    </template>-->
    <!-- <gl-dropdown-item disabled value class="disabled w-100">Select Project</gl-dropdown-item> -->
    <gl-dropdown-item
      v-for="item in list"
      :key="item.id"
      :value="item.id"
      class="w-100"
      @click="doThing"
    >{{ item.value }}</gl-dropdown-item>
  </gl-dropdown>
</template>
