# frozen_string_literal: true

require 'spec_helper'

describe Suggestion do
  let(:suggestion) { create(:suggestion) }

  describe 'associations' do
    it { is_expected.to belong_to(:diff_note) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:diff_note) }
  end

  describe '#appliable?' do
    context 'when new blob does not exists' do
      it 'returns false' do
        expect_next_instance_of(DiffNote) do |diff_note|
          allow(diff_note)
            .to receive_message_chain(:diff_file, :new_blob)
            .and_return(nil)
        end

        expect(suggestion).not_to be_appliable
      end
    end

    context 'when note not active' do
      it 'returns false' do
        expect_next_instance_of(DiffNote) do |diff_note|
          allow(diff_note).to receive(:active?) { false }
        end

        expect(suggestion).not_to be_appliable
      end
    end

    context 'when patch is already applied' do
      it 'returns false' do
        suggestion.update!(applied: true)

        expect(suggestion).not_to be_appliable
      end
    end

    context 'when current changing lines does not match persisted' do
      before do
        suggestion.update!(changing: 'something different from the file')
      end

      it 'returns false' do
        expect(suggestion).not_to be_appliable
      end
    end

    context 'when contents are the same' do
      before do
        suggestion.update!(changing: 'foo', suggestion: 'foo')
      end

      it 'returns false' do
        expect(suggestion).not_to be_appliable
      end
    end

    it 'returns true when appliable' do
      expect(suggestion).to be_appliable
    end
  end
end
