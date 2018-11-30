import { createComponentWrapper } from 'helpers/component_wrapper';

describe('~/vue_shared/components/notes/timeline_entry_item.vue', () => {
  it('renders correctly', () => {
    const wrapper = createComponentWrapper();

    expect(wrapper.is('.timeline-entry')).toBe(true);
    expect(wrapper.contains('.timeline-entry-inner')).toBe(true);
  });

  it('accepts default slot', () => {
    const dummyContent = '<p>some content</p>';
    const wrapper = createComponentWrapper({
      slots: {
        default: dummyContent,
      },
    });

    const content = wrapper.find('.timeline-entry-inner :first-child');

    expect(content.html()).toBe(dummyContent);
  });
});
