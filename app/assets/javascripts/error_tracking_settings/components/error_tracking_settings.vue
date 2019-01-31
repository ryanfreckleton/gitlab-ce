<script>
import projectDropdown from './project_dropdown.vue';
import serverConfiguration from './server_configuration.vue';

export default {
  name: 'Dropdown',
  components: { projectDropdown, serverConfiguration },
  props: {
    initialProject: {
      type: Object,
      required: false,
      default: null,
    },
  },
};
</script>

<template>
  <div>
    <serverConfiguration/>
    <projectDropdown iniital-project="initialProject"/>
  </div>
</template>
