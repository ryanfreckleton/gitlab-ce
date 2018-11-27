require 'spec_helper'

describe Suggestion do
  let(:suggestion) { create(:suggestion, relative_order: 0) }

  describe 'associations' do
    it { is_expected.to belong_to(:diff_note) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:diff_note) }
  end

  # describe '#appliable?' do
  #   context 'when note not active' do
  #     it 'returns false' do
  #     end
  #   end

  #   context 'when current changing lines does not match persisted' do
  #     it 'returns false' do
  #     end
  #   end
  # end
end
