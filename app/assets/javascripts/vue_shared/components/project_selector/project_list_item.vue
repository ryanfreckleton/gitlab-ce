<script>
import projectListItemMixin from '~/vue_shared/mixins/project_list_item';
import Icon from '~/vue_shared/components/icon.vue';
import ProjectAvatar from '~/vue_shared/components/project_avatar/default.vue';
import _ from 'underscore';

export default {
  name: 'ProjectListItem',
  components: {
    Icon,
    ProjectAvatar,
  },
  mixins: [projectListItemMixin],
  props: {
    project: {
      type: Object,
      required: true,
      validator: p => _.isFinite(p.id) && _.isString(p.name) && _.isString(p.name_with_namespace),
    },
    selected: {
      type: Boolean,
      required: true,
    },
    matcher: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    // These are some "alias" properties that allow the reuse
    // of the projectListItemMixin, which expects the following
    // properties to exist.
    itemId() {
      return this.project.id;
    },
    itemName() {
      return this.project.name;
    },
    namespace() {
      return this.project.name_with_namespace;
    },
    avatarUrl() {
      return this.project.avatar_url;
    },
  },
  methods: {
    onClick() {
      this.$emit('click');
    },
  },
};
</script>
<template>
  <button
    class="d-flex align-items-center btn pt-1 pb-1 project-list-item js-project-list-item"
    @click="onClick"
  >
    <icon
      :style="{ visibility: selected ? 'visible' : 'hidden' }"
      class="prepend-left-10 append-right-10 flex-shrink-0 js-selected-icon"
      :class="{ 'js-selected': selected, 'js-unselected': !selected }"
      name="mobile-issue-close"
    />
    <project-avatar class="flex-shrink-0 js-project-avatar" :project="project" :size="32" />
    <div class="d-flex flex-wrap">
      <div
        v-if="truncatedNamespace"
        :title="project.name_with_namespace"
        class="text-secondary js-project-namespace"
      >
        {{ truncatedNamespace }}
      </div>
      <div v-if="truncatedNamespace" class="text-secondary">&nbsp;/&nbsp;</div>
      <div :title="project.name" class="js-project-name" v-html="highlightedItemName"></div>
    </div>
  </button>
</template>
