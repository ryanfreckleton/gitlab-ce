# frozen_string_literal: true

require 'spec_helper'

describe ErrorTracking::ErrorTrackingSetting do
  it { is_expected.to belong_to(:project) }

  describe 'validations' do
    let(:project1) { create(:project) }
    subject { create(:error_tracking_setting, project: project1) }

    it 'fails validation with more than 255 chars in api_url' do
      subject.api_url = 'https://' + 'a' * 250
      expect { subject.save! }.to raise_exception(ActiveRecord::RecordInvalid, 'Validation failed: Api url is too long (maximum is 255 characters)')
    end

    it 'fails validation without token' do
      subject.token = nil
      expect { subject.save! }.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Token can't be blank")
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
