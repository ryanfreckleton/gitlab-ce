<script>
import _ from 'underscore';
import ProjectListItem from './project_list_item.vue';

const SEARCH_INPUT_TIMEOUT_MS = 500;

export default {
  name: 'ProjectSelector',
  components: {
    ProjectListItem,
  },
  props: {
    projectSearchResults: {
      type: Array,
      required: true,
    },
    selectedProjects: {
      type: Array,
      required: true,
    },
    noResults: {
      type: Boolean,
    },
  },
  data() {
    return {
      searchQuery: '',
    };
  },
  watch: {
    searchQuery: _.debounce(function debounceSearchQuery() {
      this.$emit('searched', this.searchQuery);
    }, SEARCH_INPUT_TIMEOUT_MS),
  },
  methods: {
    projectClicked(project) {
      this.$emit('projectClicked', project);
    },
    isSelected(project) {
      return !!_.findWhere(this.selectedProjects, { id: project.id });
    },
    focusSearchInput() {
      this.$refs.searchInput.focus();
    },
  },
};
</script>
<template>
  <div>
    <input
      ref="searchInput"
      v-model="searchQuery"
      :placeholder="s__('Search your projects')"
      type="search"
      class="form-control mb-3 js-project-selector-input"
      autofocus
    />
    <div class="d-flex flex-column">
      <project-list-item
        v-for="project in projectSearchResults"
        :key="project.id"
        :selected="isSelected(project)"
        :project="project"
        :matcher="searchQuery"
        @click="projectClicked(project)"
      />
      <div v-if="noResults" class="text-muted prepend-left-10 js-no-results-message">
        {{ s__('Sorry, no projects matched your search') }}
      </div>
    </div>
  </div>
</template>
