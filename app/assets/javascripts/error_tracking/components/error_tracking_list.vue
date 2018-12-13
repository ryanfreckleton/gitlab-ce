<script>
import { mapActions, mapState } from 'vuex';
import { GlEmptyState, GlButton, GlLoadingIcon, GlErrorList } from '@gitlab/ui';
import Icon from '~/vue_shared/components/icon.vue';

export default {
  components: {
    GlEmptyState,
    GlButton,
    GlLoadingIcon,
    GlErrorList,
    Icon,
  },
  props: {
    indexPath: {
      type: String,
      required: true,
    },
    enableErrorTrackingLink: {
      type: String,
      required: true,
    },
  },
  computed: {
    ...mapState(['errors', 'externalUrl', 'loadingErrors']),
    featureEnabled() {
      return gon.features.errorTracking;
    },
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
    <div v-if="featureEnabled">
      <div v-if="loadingErrors" class="py-3">
        <gl-loading-icon :size="3" />
      </div>
      <div v-else>
        <div v-if="errors.length === 0">
          <gl-empty-state
            title="No Errors :("
          />
        </div>
        <div v-else>
          <gl-button
            class="float-right m-2"
            variant="primary"
            :href="externalUrl"
            target="_blank"
          >
            View in Sentry
            <icon name="external-link" />
          </gl-button>
          <gl-error-list :errors="errors" />
        </div>
      </div>
    </div>
    <div v-else>
      <gl-empty-state
        title="Get started with error tracking"
        description="Monitor your errors by integrating with Sentry"
        primary-button-text="Enable error tracking"
        :primary-button-link="enableErrorTrackingLink"
        svg-path="https://gitlab.com/gitlab-org/gitlab-svgs/raw/master/illustrations/cluster_popover.svg"
      />
    </div>
  </div>
</template>
