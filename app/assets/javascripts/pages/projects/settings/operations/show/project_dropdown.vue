<script>
import { s__ } from '~/locale';
import Icon from '~/vue_shared/components/icon.vue';
// Similar to app/assets/javascripts/badges/components/badge.vue
// TODO: Move Me

export default {
  name: 'Dropdown',
  components: {
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
  <div class="dropdown">
    <button class="dropdown-menu-toggle js-dropdown-toggle" type="button">
      <span class="dropdown-toggle-text">
        {{ placeholderText }}
        <icon :aria-label="__('Error Tracking|Select Project')" name="chevron-down"/>
      </span>
    </button>
    <!-- <a v-show="!isLoading && !hasError" :href="linkUrl" target="_blank" rel="noopener noreferrer">
      <img
        :src="imageUrlWithRetries"
        class="project-badge"
        aria-hidden="true"
        @load="onLoad"
        @error="onError"
      >
    </a>

    <gl-loading-icon v-show="isLoading" :inline="true"/>

    <div v-show="hasError" class="btn-group">
      <div class="btn btn-default btn-sm disabled">
        <icon :size="16" class="prepend-left-8 append-right-8" name="doc-image" aria-hidden="true"/>
      </div>
      <div class="btn btn-default btn-sm disabled">
        <span class="prepend-left-8 append-right-8">{{ s__('Badges|No badge image') }}</span>
      </div>
    </div>

    <button
      v-show="hasError"
      v-gl-tooltip.hover
      :title="s__('Badges|Reload badge image')"
      class="btn btn-transparent btn-sm text-primary"
      type="button"
      @click="reloadImage"
    >
      <icon :size="16" name="retry"/>
    </button>-->
  </div>
</template>
