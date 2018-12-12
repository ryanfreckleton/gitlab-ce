# frozen_string_literal: true

require 'spec_helper'

describe Projects::ErrorTrackingHelper do
  let(:project) { create(:project) }

  include Gitlab::Routing.url_helpers

  describe '#error_tracking_data' do
    let(:index_path) do
      "/#{project.namespace.path}/#{project.path}/error_tracking"
    end

    it 'returns frontend configuration' do
      expect(error_tracking_data(project)).to eq(
        'index-path' => index_path
      )
    end
  end
end
