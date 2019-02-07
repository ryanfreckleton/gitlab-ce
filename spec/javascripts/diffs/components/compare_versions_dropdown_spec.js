import { shallowMount, createLocalVue } from '@vue/test-utils';
import CompareVersionsDropdown from '~/diffs/components/compare_versions_dropdown.vue';
import diffsMockData from '../mock_data/merge_request_diffs';

const localVue = createLocalVue();
const targetBranch = { branchName: 'tmp-wine-dev', versionIndex: -1 };
const startVersion = { version_index: 4 };
const mergeRequestVersion = {
  version_path: '123',
};

describe('CompareVersionsDropdown', () => {
  let wrapper;

  const findSelectedVersion = () => wrapper.find('.dropdown-menu-toggle');
  const findVersionsListElements = () => wrapper.findAll('li');
  const findLinkElement = index =>
    findVersionsListElements()
      .at(index)
      .find('a');
  const findLastLink = () => findLinkElement(findVersionsListElements().length - 1);

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
        mergeRequestVersion,
        startVersion,
        otherVersions: diffsMockData,
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
        startVersion,
        targetBranch,
      });

      expect(findSelectedVersion().text()).toBe('version 4');
    });
  });

  describe('target versions list', () => {
    it('should have the same length as otherVersions if merge request version is present', () => {
      createComponent({
        mergeRequestVersion,
        otherVersions: diffsMockData,
      });

      expect(findVersionsListElements().length).toEqual(diffsMockData.length);
    });

    it('should have an otherVersions length plus 1 if no merge request version is present', () => {
      createComponent({
        targetBranch,
        otherVersions: diffsMockData,
      });

      expect(findVersionsListElements().length).toEqual(diffsMockData.length + 1);
    });

    it('should have base branch link as active on base branch', () => {
      createComponent({
        targetBranch,
        otherVersions: diffsMockData,
      });

      expect(findLastLink().classes()).toContain('is-active');
    });

    it('should have correct branch link as active if start version present', () => {
      createComponent({
        targetBranch,
        startVersion,
        otherVersions: diffsMockData,
      });

      expect(findLinkElement(0).classes()).toContain('is-active');
    });

    it('should render a correct base version link', () => {
      createComponent({
        baseVersionPath: '/gnuwget/wget2/merge_requests/6/diffs?diff_id=37',
        otherVersions: diffsMockData.slice(1),
        targetBranch,
      });

      expect(findLastLink().attributes('href')).toEqual(wrapper.props('baseVersionPath'));
      expect(findLastLink().text()).toContain('(base)');
    });
  });
});
