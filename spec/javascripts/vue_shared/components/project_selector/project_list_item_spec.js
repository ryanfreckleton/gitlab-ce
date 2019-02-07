import Vue from 'vue';
import ProjectListItem from '~/vue_shared/components/project_selector/project_list_item.vue';
import mountComponent from 'spec/helpers/vue_mount_component_helper';
import { trimText } from 'spec/helpers/vue_component_helper';
import getMockProjects from './mock_data';

describe('ProjectListItem component', () => {
  let vm;
  const [project] = getMockProjects(1);

  beforeEach(() => {
    vm = mountComponent(Vue.extend(ProjectListItem), {
      project,
      selected: false,
    });
  });

  afterEach(() => {
    vm.$destroy();
  });

  it('does not render a check mark icon if selected === false', () => {
    expect(vm.$el.querySelector('.js-selected-icon.js-unselected')).toBeTruthy();
  });

  it('renders a check mark icon if selected === true', done => {
    vm.selected = true;

    vm.$nextTick(() => {
      expect(vm.$el.querySelector('.js-selected-icon.js-selected')).toBeTruthy();
      done();
    });
  });

  it(`emits a "clicked" event when clicked`, () => {
    spyOn(vm, '$emit');
    vm.$el.click();

    expect(vm.$emit).toHaveBeenCalledWith('click');
  });

  it(`renders the project avatar`, () => {
    expect(vm.$el.querySelector('.js-project-avatar')).toBeTruthy();
  });

  it(`renders a simple namespace name`, done => {
    project.name_with_namespace = 'a / b';

    vm.$nextTick(() => {
      const renderedNamespace = trimText(vm.$el.querySelector('.js-project-namespace').textContent);

      expect(renderedNamespace).toBe('a');
      done();
    });
  });

  it(`renders a properly truncate namespace`, done => {
    project.name_with_namespace = 'a / b / c / d / e / f';

    vm.$nextTick(() => {
      const renderedNamespace = trimText(vm.$el.querySelector('.js-project-namespace').textContent);

      expect(renderedNamespace).toBe('a / ... / e');
      done();
    });
  });

  it(`renders the project name`, done => {
    project.name = 'my-test-project';

    vm.$nextTick(() => {
      const renderedName = trimText(vm.$el.querySelector('.js-project-name').innerHTML);

      expect(renderedName).toBe('my-test-project');
      done();
    });
  });

  it(`renders the project name with highlighting in the case of a search query match`, done => {
    project.name = 'my-test-project';
    vm.matcher = 'pro';

    vm.$nextTick(() => {
      const renderedName = trimText(vm.$el.querySelector('.js-project-name').innerHTML);

      expect(renderedName).toBe('my-test-<b>pro</b>ject');
      done();
    });
  });
});
