import Vuex from 'vuex';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import { GlLoadingIcon } from '@gitlab/ui';
import { TEST_HOST } from 'spec/test_constants';
import App from '~/diffs/components/app.vue';
import NoChanges from '~/diffs/components/no_changes.vue';
import DiffFile from '~/diffs/components/diff_file.vue';
import CompareVersions from '~/diffs/components/compare_versions.vue';
import HiddenFilesWarning from '~/diffs/components/hidden_files_warning.vue';
import CommitWidget from '~/diffs/components/commit_widget.vue';
import createDiffsStore from '../create_diffs_store';

describe('diffs/components/app', () => {
  const oldMrTabs = window.mrTabs;
  let store;
  let vm;

  function createComponent(props = {}, extendStore = () => {}) {
    const localVue = createLocalVue();

    localVue.use(Vuex);

    store = createDiffsStore();
    store.state.diffs.isLoading = false;

    extendStore(store);

    vm = shallowMount(localVue.extend(App), {
      localVue,
      propsData: {
        endpoint: `${TEST_HOST}/diff/endpoint`,
        projectPath: 'namespace/project',
        currentUser: {},
        changesEmptyStateIllustration: '',
        ...props,
      },
      store,
    });
  }

  beforeEach(() => {
    // setup globals (needed for component to mount :/)
    window.mrTabs = jasmine.createSpyObj('mrTabs', ['resetViewContainer']);
    window.mrTabs.expandViewContainer = jasmine.createSpy();
    window.location.hash = 'ABC_123';
  });

  afterEach(() => {
    // reset globals
    window.mrTabs = oldMrTabs;

    // reset component
    vm.destroy();
  });

  it('displays loading icon on loading', () => {
    createComponent({}, () => {
      store.state.diffs.isLoading = true;
    });

    expect(vm.contains(GlLoadingIcon)).toBe(true);
  });

  it('displays diffs container when not loading', () => {
    createComponent();

    expect(vm.contains(GlLoadingIcon)).toBe(false);
    expect(vm.contains('#diffs')).toBe(true);
  });

  it('does not show commit info', () => {
    createComponent();

    expect(vm.contains('.blob-commit-info')).toBe(false);
  });

  it('sets highlighted row if hash exists in location object', done => {
    createComponent({
      shouldShow: true,
    });

    // Component uses $nextTick so we wait until that has finished
    setTimeout(() => {
      expect(store.state.diffs.highlightedRow).toBe('ABC_123');

      done();
    });
  });

  describe('empty state', () => {
    it('renders empty state when no diff files exist', () => {
      createComponent();

      expect(vm.contains(NoChanges)).toBe(true);
    });

    it('does not render empty state when diff files exist', () => {
      createComponent({}, () => {
        store.state.diffs.diffFiles.push({
          id: 1,
        });
      });

      expect(vm.contains(NoChanges)).toBe(false);
      expect(vm.findAll(DiffFile).length).toBe(1);
    });

    it('does not render empty state when versions match', () => {
      createComponent({}, () => {
        store.state.diffs.startVersion = { version_index: 1 };
        store.state.diffs.mergeRequestDiff = { version_index: 1 };
      });

      expect(vm.contains(NoChanges)).toBe(false);
    });
  });

  describe('diffs', () => {
    it('should render compare versions component', () => {
      createComponent();

      expect(vm.contains(CompareVersions));
    });

    it('should render hidden files warning if render overflow warning is present', () => {
      createComponent({}, () => {
        store.state.diffs.renderOverflowWarning = true;
        store.state.diffs.realSize = '5';
        store.state.diffs.plainDiffPath = 'plain diff path';
        store.state.diffs.emailPatchPath = 'email patch path';
        store.state.diffs.size = 1;
      });

      expect(vm.contains(HiddenFilesWarning)).toBe(true);
    });

    it('should display commit widget if store has a commit', () => {
      createComponent({}, () => {
        store.state.diffs.commit = {
          author: 'John Doe',
        };
      });

      expect(vm.contains(CommitWidget)).toBe(true);
    });

    it('should display diff file if there are diff files', () => {
      createComponent({}, () => {
        store.state.diffs.diffFiles.push({ sha: '123' });
      });

      expect(vm.contains(CommitWidget)).toBe(true);
    });
  });
});
