# frozen_string_literal: true

require 'spec_helper'

describe ErrorTracking::ErrorTrackingSetting do
  describe 'Associations' do
    it { is_expected.to belong_to(:project) }
  end

  describe 'Validations' do
    let(:project1) { create(:project) }

    subject { create(:error_tracking_setting, project: project1) }

    context 'when api_url is over 255 chars' do
      before do
        subject.api_url = 'https://' + 'a' * 250
      end

      it 'fails validation' do
        expect(subject).not_to be_valid
        expect(subject.errors.messages[:api_url]).to include('is too long (maximum is 255 characters)')
      end
    end
  end

  describe '#api_url' do
    let(:project) { create(:project) }
    let(:error_tracking_setting) { create(:error_tracking_setting, project: project) }

    it 'sanitizes the api url' do
      error_tracking_setting.api_url = "https://replaceme.com/'><script>alert(document.cookie)</script>"
      expect(error_tracking_setting).to be_valid
      expect(error_tracking_setting.api_url).to eq("https://replaceme.com/'>")
    end
  end
end
