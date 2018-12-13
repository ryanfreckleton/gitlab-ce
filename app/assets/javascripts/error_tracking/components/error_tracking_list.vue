<script>
import { mapActions, mapState } from 'vuex';
import { GlEmptyState, GlLoadingIcon } from '@gitlab/ui';

export default {
  components: {
    GlEmptyState,
    GlLoadingIcon,
  },
  props: {
    indexPath: {
      type: String,
      required: true,
    },
  },
  computed: {
    ...mapState(['errors', 'loadingErrors']),
  },
  methods: {
    ...mapActions(['getErrorList']),
  },
  created() {
    this.getErrorList(this.indexPath);
  },
}
</script>

<template>
  <div>
    <div v-if="loadingErrors" class="py-3">
      <gl-loading-icon :size="3" />
    </div>
    <div v-else-if="errors.length === 0">
      <gl-empty-state
        title="No Errors :("
      />
    </div>
    <div v-else>
      {{ errors }}
    </div>
  </div>
</template>
