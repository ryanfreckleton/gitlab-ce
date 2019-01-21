# frozen_string_literal: true

require 'spec_helper'

describe Ci::CreateBuildAnnotationsWorker do
  describe '#perform' do
    context 'when the CI build does not exist' do
      it 'does nothing' do
        expect(Ci::CreateBuildAnnotationsService)
          .not_to receive(:new)

        described_class.new.perform(-1)
      end
    end

    context 'when the CI build exists' do
      it 'creates the build annotations for the build' do
        build = create(:ci_build)
        worker = described_class.new
        service = instance_spy(Ci::CreateBuildAnnotationsService)

        allow(Ci::CreateBuildAnnotationsService)
          .to receive(:new)
          .with(build)
          .and_return(service)

        allow(service)
          .to receive(:execute)

        worker.perform(build.id)

        expect(service)
          .to have_received(:execute)
      end
    end
  end
end
