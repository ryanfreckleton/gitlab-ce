require 'spec_helper'

describe Suggestion do
  let(:suggestion) { create(:suggestion, position: 0) }

  describe '#appliable?' do
    context 'when note not active' do
      it 'returns false' do
      end
    end

    context 'when current changing lines does not match persisted' do
      it 'returns false' do
      end
    end
  end
end
