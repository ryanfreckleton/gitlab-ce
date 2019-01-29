<script>
import IssueStatusIcon from '~/reports/components/issue_status_icon.vue';
import { components, componentNames } from '~/reports/components/issue_body';

export default {
  name: 'ReportItem',
  components: {
    IssueStatusIcon,
    ...components,
  },
  props: {
    issue: {
      type: Object,
      required: true,
    },
    component: {
      type: String,
      required: false,
      default: '',
      validator: value => value === '' || Object.values(componentNames).includes(value),
    },
    // failed || success
    status: {
      type: String,
      required: true,
    },
    isNew: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
};
</script>
<template>
  <li :class="{ 'is-dismissed': issue.isDismissed }" class="report-block-list-issue">
    <span v-if="issue.isDismissed" class="prepend-top-5 mx-2">DISMISSED</span>
    <issue-status-icon v-else :status="status" class="append-right-5" />
    <component :is="component" v-if="component" :issue="issue" :status="status" :is-new="isNew" />
  </li>
</template>
