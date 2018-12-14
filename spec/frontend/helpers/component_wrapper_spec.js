import { Wrapper, shallowMount } from '@vue/test-utils'
import { createComponentWrapper } from './component_wrapper';

describe('component wrapper helper', () => {
  describe('createComponentWrapper', () => {
    it('returns a Wrapper instance', () => {
      const wrapper = createComponentWrapper();
      
      expect(wrapper).toBe(expect.any(Wrapper))
    })

    it('calls shallowMount with options and localVue', () => {
      jest.mock('@vue/test-utils');
      const propsData = {
        some: 'thing'
      };

      createComponentWrapper({
        propsData
      })

      expect(shallowMount).toHaveBeenCalledTimes(1)
      const options = shallowMount.mock.calls[0];

    });
  })
});