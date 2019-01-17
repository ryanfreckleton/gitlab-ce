RSpec.shared_examples 'issuable state' do
  it 'exposes all the existing issuable states' do
    actual_states = Hash[described_class.values.map { |_, v| [v.name, v.value] }]
    expected_states = %w[opened closed locked].map { |s| [s, s] }.to_h

    expect(actual_states).to include(expected_states)
  end
end
