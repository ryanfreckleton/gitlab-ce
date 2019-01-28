# frozen_string_literal: true

require 'spec_helper'

describe Clusters::Applications::CheckUpgradeProgressService do
  RESCHEDULE_PHASES = ::Gitlab::Kubernetes::Pod::PHASES -
    [::Gitlab::Kubernetes::Pod::SUCCEEDED, ::Gitlab::Kubernetes::Pod::FAILED].freeze

  let(:application) { create(:clusters_applications_prometheus, :updating) }
  let(:service) { described_class.new(application) }
  let(:phase) { ::Gitlab::Kubernetes::Pod::UNKNOWN }
  let(:errors) { nil }
  let(:worker_class) { ClusterWaitForAppUpdateWorker }

  shared_examples 'a not yet terminated pod phase' do |a_phase|
    let(:phase) { a_phase }

    before do
      expect(service).to receive(:phase).once.and_return(phase)
    end

    context "when phase is #{a_phase}" do
      context 'when not timed out' do
        it 'reschedule a new check' do
          expect(worker_class).to receive(:perform_in).once
          expect(service).not_to receive(:remove_pod)

          service.execute

          expect(application).to be_updating
          expect(application.status_reason).to be_nil
        end
      end

      context 'when timed out' do
        let(:application) { create(:clusters_applications_prometheus, :timeouted, :updating) }

        it 'make the application update errored' do
          expect(worker_class).not_to receive(:perform_in)

          service.execute

          expect(application).to be_update_errored
          expect(application.status_reason).to eq("Update timed out. Check pod logs for upgrade-prometheus for more details.")
        end
      end
    end
  end

  before do
    allow(service).to receive(:remove_pod).and_return(nil)
  end

  describe '#execute' do
    context 'when upgrade pod succeeded' do
      let(:phase) { ::Gitlab::Kubernetes::Pod::SUCCEEDED }

      before do
        expect(service).to receive(:phase).once.and_return(phase)
      end

      it 'removes the upgrade pod' do
        expect(service).to receive(:remove_pod).once

        service.execute
      end

      it 'make the application upgraded' do
        expect(worker_class).not_to receive(:perform_in)

        service.execute

        expect(application).to be_updated
        expect(application.status_reason).to be_nil
      end
    end

    context 'when upgrade pod failed' do
      let(:phase) { ::Gitlab::Kubernetes::Pod::FAILED }
      let(:errors) { 'test installation failed' }

      before do
        expect(service).to receive(:phase).once.and_return(phase)
      end

      it 'make the application update errored' do
        service.execute

        expect(application).to be_update_errored
        expect(application.status_reason).to eq("Update failed. Check pod logs for upgrade-prometheus for more details.")
      end
    end

    RESCHEDULE_PHASES.each { |phase| it_behaves_like 'a not yet terminated pod phase', phase }

    context 'when upgrade raises a Kubeclient::HttpError' do
      let(:cluster) { create(:cluster, :provided_by_user, :project) }

      before do
        application.update!(cluster: cluster)

        expect(service).to receive(:phase).and_raise(Kubeclient::HttpError.new(401, 'Unauthorized', nil))
      end

      it 'shows the response code from the error' do
        service.execute

        expect(application).to be_update_errored
        expect(application.status_reason).to eq('Kubernetes error: 401')
      end

      it 'should log error' do
        expect(service.send(:logger)).to receive(:error)

        service.execute
      end
    end
  end
end
