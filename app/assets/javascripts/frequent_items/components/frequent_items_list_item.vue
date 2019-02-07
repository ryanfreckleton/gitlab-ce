<script>
/* eslint-disable vue/require-default-prop */
import Identicon from '../../vue_shared/components/identicon.vue';
import projectListItemMixin from '~/vue_shared/mixins/project_list_item';

export default {
  components: {
    Identicon,
  },
  mixins: [projectListItemMixin],
  props: {
    matcher: {
      type: String,
      required: false,
    },
    itemId: {
      type: Number,
      required: true,
    },
    itemName: {
      type: String,
      required: true,
    },
    namespace: {
      type: String,
      required: false,
    },
    webUrl: {
      type: String,
      required: true,
    },
    avatarUrl: {
      required: true,
      validator(value) {
        return value === null || typeof value === 'string';
      },
    },
  },
};
</script>

<template>
  <li class="frequent-items-list-item-container">
    <a :href="webUrl" class="clearfix">
      <div class="frequent-items-item-avatar-container">
        <img v-if="hasAvatar" :src="avatarUrl" class="avatar s32" />
        <identicon v-else :entity-id="itemId" :entity-name="itemName" size-class="s32" />
      </div>
      <div class="frequent-items-item-metadata-container">
        <div :title="itemName" class="frequent-items-item-title" v-html="highlightedItemName"></div>
        <div v-if="truncatedNamespace" :title="namespace" class="frequent-items-item-namespace">
          {{ truncatedNamespace }}
        </div>
      </div>
    </a>
  </li>
</template>
