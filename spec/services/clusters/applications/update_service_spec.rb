# frozen_string_literal: true

require 'spec_helper'

describe Clusters::Applications::UpdateService do
  describe '#execute' do
    let(:application) { create(:clusters_applications_prometheus, :installed) }
    let(:project) { application.cluster.project }
    let(:service) { described_class.new(application, project) }
    let(:helm_client) { instance_double(Gitlab::Kubernetes::Helm::Api) }

    before do
      allow(service).to receive(:helm_api).and_return(helm_client)
    end

    context 'when there are no errors' do
      before do
        expect(helm_client).to receive(:update).with(kind_of(Gitlab::Kubernetes::Helm::UpgradeCommand))

        allow(::ClusterWaitForAppUpdateWorker)
          .to receive(:perform_in)
          .and_return(nil)
      end

      it 'makes the application updating' do
        service.execute

        expect(application).to be_updating
      end

      it 'schedules async update status check' do
        expect(::ClusterWaitForAppUpdateWorker).to receive(:perform_in).once

        service.execute
      end
    end

    context 'when k8s cluster communication fails' do
      let(:error) { Kubeclient::HttpError.new(500, 'system failure', nil) }

      before do
        expect(helm_client).to receive(:update).with(kind_of(Gitlab::Kubernetes::Helm::UpgradeCommand)).and_raise(error)
      end

      it 'make the application update_errored' do
        service.execute

        expect(application).to be_update_errored
        expect(application.status_reason).to match('Kubernetes error: 500')
      end

      it 'logs errors' do
        expect(service.send(:logger)).to receive(:error).with(
          {
            exception: 'Kubeclient::HttpError',
            message: 'system failure',
            service: 'Clusters::Applications::UpdateService',
            app_id: application.id,
            project_ids: application.cluster.project_ids,
            group_ids: [],
            error_code: 500
          }
        )

        expect(Gitlab::Sentry).to receive(:track_acceptable_exception).with(
          error,
          extra: {
            exception: 'Kubeclient::HttpError',
            message: 'system failure',
            service: 'Clusters::Applications::UpdateService',
            app_id: application.id,
            project_ids: application.cluster.project_ids,
            group_ids: [],
            error_code: 500
          }
        )

        service.execute
      end
    end

    context 'a non kubernetes error happens' do
      let(:error) { StandardError.new("something bad happened") }

      before do
        expect(application).to receive(:make_updating!).once.and_raise(error)
      end

      it 'make the application update_errored' do
        expect(helm_client).not_to receive(:update)

        service.execute

        expect(application).to be_update_errored
        expect(application.status_reason).to eq("Can't start installation process.")
      end

      it 'logs errors' do
        expect(service.send(:logger)).to receive(:error).with(
          {
            exception: 'StandardError',
            error_code: nil,
            message: 'something bad happened',
            service: 'Clusters::Applications::UpdateService',
            app_id: application.id,
            project_ids: application.cluster.projects.pluck(:id),
            group_ids: []
          }
        )

        expect(Gitlab::Sentry).to receive(:track_acceptable_exception).with(
          error,
          extra: {
            exception: 'StandardError',
            error_code: nil,
            message: 'something bad happened',
            service: 'Clusters::Applications::UpdateService',
            app_id: application.id,
            project_ids: application.cluster.projects.pluck(:id),
            group_ids: []
          }
        )

        service.execute
      end
    end
  end
end
