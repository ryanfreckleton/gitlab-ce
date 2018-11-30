import { createLocalVue, shallowMount } from '@vue/test-utils';
import { testFile } from './test_file';

let wrapper;

export const destroyComponentWrapper = () => {
  if (!wrapper) {
    return;
  }

  wrapper.destroy();

  // ensure the garbage collector can pick up the wrapper instance
  wrapper = null;
};

export const createComponentWrapper = (options = {}) => {
  if (wrapper) {
    throw new Error(
      'There is still a wrapper instance. You need to call destroyComponentWrapper() before creating a new one.',
    );
  }

  const componentPath = testFile.description;

  // the following is fine because Jest runs in node.js environment
  // eslint-disable-next-line global-require, import/no-dynamic-require
  const component = require(componentPath);
  const localVue = createLocalVue();
  wrapper = shallowMount(component, {
    localVue,
    ...options,
  });

  return wrapper;
};
