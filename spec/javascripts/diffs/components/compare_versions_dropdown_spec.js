import { shallowMount, createLocalVue } from '@vue/test-utils';
import CompareVersionsDropdown from '~/diffs/components/compare_versions_dropdown.vue';
import diffsMockData from '../mock_data/merge_request_diffs';

const localVue = createLocalVue();
const targetBranch = { branchName: 'tmp-wine-dev', versionIndex: -1 };

describe('CompareVersionsDropdown', () => {
  let wrapper;

  const findSelectedVersion = () => wrapper.find('.dropdown-menu-toggle');

  const createComponent = (props = {}) => {
    wrapper = shallowMount(CompareVersionsDropdown, {
      localVue,
      sync: false,
      propsData: { ...props },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('selected version name', () => {
    it('shows latest version when latest is selected', () => {
      createComponent({
        mergeRequestVersion: {
          version_path: '123',
        },
        startVersion: {
          version_index: '1',
        },
        otherVersions: [
          {
            version_index: '1',
          },
        ],
      });

      expect(findSelectedVersion().text()).toBe('latest version');
    });

    it('shows target branch name for base branch', () => {
      createComponent({
        targetBranch,
      });

      expect(findSelectedVersion().text()).toBe('tmp-wine-dev');
    });

    it('shows correct version for non-base and non-latest branches', () => {
      createComponent({
        startVersion: {
          version_index: '1',
        },
        targetBranch,
      });

      expect(findSelectedVersion().text()).toBe('version 1');
    });
  });

  it('should render a correct base version link', () => {
    createComponent({
      baseVersionPath: '/gnuwget/wget2/merge_requests/6/diffs?diff_id=37',
      otherVersions: diffsMockData.slice(1),
      targetBranch,
    });

    const links = wrapper.findAll('a');
    const lastLink = links.wrappers[links.length - 1];

    expect(lastLink.attributes('href')).toEqual(wrapper.props('baseVersionPath'));
  });
});
