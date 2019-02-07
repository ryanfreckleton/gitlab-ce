import Vue from 'vue';
import _ from 'underscore';
import ProjectSelector from '~/vue_shared/components/project_selector/project_selector.vue';
import mountComponent from 'spec/helpers/vue_mount_component_helper';
import { trimText } from 'spec/helpers/vue_component_helper';
import getMockProjects from './mock_data';

describe('ProjectSelector component', () => {
  let vm;
  const allProjects = getMockProjects(10);
  const searchResults = allProjects.slice(0, 5);
  let selected = [];
  selected = selected.concat(allProjects.slice(0, 3));
  selected = selected.concat(allProjects.slice(5, 8));

  beforeEach(() => {
    // mount the component in the DOM so that we can
    // test document.activeElement
    const vmContainer = document.createElement('div');
    document.querySelector('body').appendChild(vmContainer);

    jasmine.clock().install();
    vm = mountComponent(
      Vue.extend(ProjectSelector),
      {
        projectSearchResults: searchResults,
        selectedProjects: selected,
        noResults: false,
      },
      vmContainer,
    );
  });

  afterEach(() => {
    jasmine.clock().uninstall();
    vm.$destroy();
  });

  it('renders the search results', () => {
    expect(vm.$el.querySelectorAll('.js-project-list-item').length).toBe(5);
  });

  it('renders checkmarks by the selected projects that are currently shown', () => {
    expect(vm.$el.querySelectorAll('.js-selected-icon.js-selected').length).toBe(3);
  });

  it(`triggers a (debounced) search when the search input value changes`, done => {
    spyOn(vm, '$emit');
    const query = 'my test query';
    vm.searchQuery = query;
    vm.$nextTick(() => {
      expect(vm.$emit).not.toHaveBeenCalledWith();
      jasmine.clock().tick(501);

      expect(vm.$emit).toHaveBeenCalledWith('searched', query);
      done();
    });
  });

  it(`debounces the search input`, done => {
    spyOn(vm, '$emit');

    const updateSearchQuery = (count = 0) => {
      if (count === 10) {
        jasmine.clock().tick(101);

        expect(vm.$emit).toHaveBeenCalledTimes(1);
        expect(vm.$emit).toHaveBeenCalledWith('searched', `search query #9`);
        done();
      } else {
        vm.searchQuery = `search query #${count}`;
        vm.$nextTick(() => {
          jasmine.clock().tick(400);
          updateSearchQuery(count + 1);
        });
      }
    };

    updateSearchQuery();
  });

  it(`includes a placeholder in the search box`, () => {
    expect(vm.$el.querySelector('.js-project-selector-input').placeholder).toBe(
      'Search your projects',
    );
  });

  it(`triggers a "projectClicked" event when a project is clicked`, () => {
    spyOn(vm, '$emit');
    vm.$el.querySelector('.js-project-list-item').click();

    expect(vm.$emit).toHaveBeenCalledWith('projectClicked', _.first(searchResults));
  });

  it(`shows a "no results" message if is a non-empty search query but no results`, done => {
    vm.noResults = true;

    vm.$nextTick(() => {
      const noResultsEl = vm.$el.querySelector('.js-no-results-message');

      expect(noResultsEl).toBeTruthy();

      expect(trimText(noResultsEl.textContent)).toEqual('Sorry, no projects matched your search');

      done();
    });
  });

  it(`focuses the input element when the focusSearchInput() method is called`, () => {
    const input = vm.$el.querySelector('.js-project-selector-input');

    expect(document.activeElement).not.toBe(input);
    vm.focusSearchInput();

    expect(document.activeElement).toBe(input);
  });
});
