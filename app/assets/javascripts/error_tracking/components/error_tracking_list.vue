<script>
import { mapActions, mapState } from 'vuex';

export default {
  props: {
    indexPath: {
      type: String,
      required: true,
    },
  },
  computed: {
    ...mapState(['errors']),
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
    {{ errors }}
  </div>
</template>
