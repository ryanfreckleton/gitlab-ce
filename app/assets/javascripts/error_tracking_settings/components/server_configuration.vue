<script>
import { s__ } from '~/locale';
import Icon from '~/vue_shared/components/icon.vue';

import { GlFormGroup, GlFormInput } from '@gitlab/ui';

export default {
  name: 'Dropdown',
  components: { GlFormGroup, GlFormInput, Icon },
  props: {},
  data() {
    return {
      connectText: s__('Connect'),
      tokenDescription: s__(
        "After adding your Auth Token, use the 'Connect' button to load projects",
      ),
      urlDescription: s__('Find your hostname in your Sentry account settings page'),
      urlPlaceholder: s__('https://mysentryserver.com'),
      token: '',
      apiUrl: '',
    };
  },
  computed: {},
  methods: {
    handleClick() {
      console.log(this.apiUrl, this.token);
    },
  },
};
</script>

<template>
  <!-- TODO: Translate labels -->
  <div>
    <gl-form-group label="Sentry API URL" label-class="label-bold" label-for="input2">
      <gl-form-input id="input2" v-model="apiUrl" :placeholder="urlPlaceholder"/>
      <p class="form-text text-muted">{{ urlDescription }}</p>
    </gl-form-group>
    <gl-form-group label="Auth Token" label-class="label-bold" label-for="input1">
      <gl-form-input
        id="input1"
        v-model="token"
        class="form-control form-control-inline"
        style="width: auto;"
      />
      <div class="btn btn-success prepend-left-10" @click="handleClick">{{ connectText }}</div>
      <p class="form-text text-muted">{{ tokenDescription }}</p>
    </gl-form-group>
  </div>
</template>
