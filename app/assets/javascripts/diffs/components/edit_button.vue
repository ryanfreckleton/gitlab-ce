<script>
import Icon from '~/vue_shared/components/icon.vue';

export default {
  components: {
    Icon,
  },
  props: {
    editPath: {
      type: String,
      required: true,
    },
    canCurrentUserFork: {
      type: Boolean,
      required: true,
    },
    canModifyBlob: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  methods: {
    handleEditClick(evt) {
      if (!this.canCurrentUserFork || this.canModifyBlob) {
        // if we can Edit, do default Edit button behavior
        return;
      }

      if (this.canCurrentUserFork) {
        evt.preventDefault();
        this.$emit('showForkMessage');
      }
    },
  },
  expandFullDiffEnabled: gon.features.expandFullDiff,
};
</script>

<template>
  <a :href="editPath" class="btn btn-default js-edit-blob" @click="handleEditClick">
    <icon v-if="$options.expandFullDiffEnabled" name="pencil" />
    <template v-else>
      {{ __('Edit') }}
    </template>
  </a>
</template>
