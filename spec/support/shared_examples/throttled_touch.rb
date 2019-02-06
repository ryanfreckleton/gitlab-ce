shared_examples_for 'throttled touch' do
  describe '#touch' do
    it 'updates the updated_at timestamp' do
      Timecop.freeze do
        subject.touch
        expect(subject.updated_at).to be_like_time(Time.zone.now)
      end
    end

    context 'when updating more than once per minute' do
      let(:first_updated_at) { Time.zone.now - (ThrottledTouch::TOUCH_INTERVAL * 2) }
      let(:second_updated_at) { Time.zone.now - (ThrottledTouch::TOUCH_INTERVAL * 1.5) }

      before do
        Timecop.freeze(first_updated_at) { subject.touch }
      end

      it 'does not update the timestamp' do
        Timecop.freeze(second_updated_at) { subject.touch }

        expect(subject.updated_at).to be_like_time(first_updated_at)
      end

      it 'updates the timestamp when `force` is true' do
        Timecop.freeze(second_updated_at) { subject.touch(force: true) }

        expect(subject.updated_at).to be_like_time(second_updated_at)
      end
    end
  end
end
