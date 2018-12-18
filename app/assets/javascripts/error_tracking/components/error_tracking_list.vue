<script>
import { mapActions, mapState } from 'vuex';
import { GlEmptyState, GlButton, GlLink, GlLoadingIcon, GlTable } from '@gitlab/ui';
import Icon from '~/vue_shared/components/icon.vue';
import TimeAgo from '~/vue_shared/components/time_ago_tooltip.vue';

export default {
  fields: [
    'error',
    'count',
    'user_count',
    'lastSeen',
  ],
  components: {
    GlEmptyState,
    GlButton,
    GlLink,
    GlLoadingIcon,
    GlTable,
    Icon,
    TimeAgo,
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
          <div class="d-flex justify-content-end">
            <gl-button
              class="my-3 ml-auto"
              variant="primary"
              :href="externalUrl"
              target="_blank"
            >
              View in Sentry
              <icon name="external-link" />
            </gl-button>
          </div>
          <gl-table
            :items="errors"
            :fields="$options.fields"
          >
            <template slot="error" slot-scope="errors">
              <div class="d-flex flex-column">
                <div class="d-flex">
                  <gl-link :href="errors.item.external_url" class="d-flex text-dark">
                    <strong>{{ errors.item.title.trim() }}</strong>
                    <icon name="external-link" class="ml-1" />
                  </gl-link>
                  <span class="text-secondary ml-2">{{ errors.item.culprit }}</span>
                </div>
                {{ errors.item.message }}
              </div>
            </template>
            <template slot="lastSeen" slot-scope="errors">
              <icon name="calendar" />
              <time-ago :time="errors.item.last_seen" />
            </template>
          </gl-table>
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
