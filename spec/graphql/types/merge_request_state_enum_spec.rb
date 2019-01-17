# frozen_string_literal: true

require 'spec_helper'

describe GitlabSchema.types['MergeRequestState'] do
  it { expect(described_class.graphql_name).to eq('MergeRequestState') }

  it_behaves_like 'issuable state'

  it 'exposes all the existing merge request states' do
    actual_states = Hash[described_class.values.map { |_, v| [v.name, v.value] }]
    expected_states = %w[opened closed locked merged].map { |s| [s, s] }.to_h

    expect(actual_states['merged']).to eq(expected_states['merged'])
  end
end
