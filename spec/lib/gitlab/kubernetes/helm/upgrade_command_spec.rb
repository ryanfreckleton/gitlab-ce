# frozen_string_literal: true

require 'rails_helper'

describe Gitlab::Kubernetes::Helm::UpgradeCommand do
  let(:files) { { 'ca.pem': 'some file content' } }
  let(:namespace) { ::Gitlab::Kubernetes::Helm::NAMESPACE }
  let(:rbac) { false }

  let(:upgrade_command) do
    described_class.new(
      'app-name',
      chart: 'app-chart',
      files: files,
      rbac: rbac
    )
  end

  let(:tls_flags) do
    "--tls --tls-ca-cert /data/helm/app-name/config/ca.pem --tls-cert /data/helm/app-name/config/cert.pem --tls-key /data/helm/app-name/config/key.pem"
  end

  subject { upgrade_command }

  it_behaves_like 'helm commands' do
    let(:commands) do
      <<~EOS
         helm init --upgrade
         for i in $(seq 1 30); do helm version && break; sleep 1s; echo "Retrying ($i)..."; done
         helm upgrade app-name app-chart #{tls_flags} --set rbac.create\\=false,rbac.enabled\\=false --reset-values --install --namespace #{namespace} -f /data/helm/app-name/config/values.yaml
      EOS
    end
  end

  context 'rbac is true' do
    let(:rbac) { true }

    it_behaves_like 'helm commands' do
      let(:commands) do
        <<~EOS
         helm init --upgrade
         for i in $(seq 1 30); do helm version && break; sleep 1s; echo "Retrying ($i)..."; done
         helm upgrade app-name app-chart #{tls_flags} --set rbac.create\\=true,rbac.enabled\\=true --reset-values --install --namespace #{namespace} -f /data/helm/app-name/config/values.yaml
        EOS
      end
    end
  end

  context 'with an application with a repository' do
    let(:ci_runner) { create(:ci_runner) }
    let(:upgrade_command) do
      described_class.new(
        'app-name',
        chart: 'app-chart',
        files: files,
        rbac: rbac,
        repository: 'https://repository.example.com'
      )
    end

    it_behaves_like 'helm commands' do
      let(:commands) do
        <<~EOS
           helm init --upgrade
           for i in $(seq 1 30); do helm version && break; sleep 1s; echo "Retrying ($i)..."; done
           helm repo add app-name https://repository.example.com
           helm repo update
           helm upgrade app-name app-chart #{tls_flags} --set rbac.create\\=false,rbac.enabled\\=false --reset-values --install --namespace #{namespace} -f /data/helm/app-name/config/values.yaml
        EOS
      end
    end
  end

  context 'when there is no ca.pem file' do
    let(:files) { { 'file.txt': 'some content' } }

    it_behaves_like 'helm commands' do
      let(:commands) do
        <<~EOS
         helm init --upgrade
         for i in $(seq 1 30); do helm version && break; sleep 1s; echo "Retrying ($i)..."; done
         helm upgrade app-name app-chart --set rbac.create\\=false,rbac.enabled\\=false --reset-values --install --namespace #{namespace} -f /data/helm/app-name/config/values.yaml
        EOS
      end
    end
  end

  describe '#pod_resource' do
    subject { upgrade_command.pod_resource }

    context 'rbac is enabled' do
      let(:rbac) { true }

      it 'generates a pod that uses the tiller serviceAccountName' do
        expect(subject.spec.serviceAccountName).to eq('tiller')
      end
    end

    context 'rbac is not enabled' do
      let(:rbac) { false }

      it 'generates a pod that uses the default serviceAccountName' do
        expect(subject.spec.serviceAcccountName).to be_nil
      end
    end
  end

  describe '#config_map_resource' do
    let(:metadata) do
      {
        name: "values-content-configuration-app-name",
        namespace: namespace,
        labels: { name: "values-content-configuration-app-name" }
      }
    end
    let(:resource) { ::Kubeclient::Resource.new(metadata: metadata, data: files) }

    it 'returns a KubeClient resource with config map content for the application' do
      expect(subject.config_map_resource).to eq(resource)
    end
  end

  describe '#rbac?' do
    subject { upgrade_command.rbac? }

    context 'rbac is enabled' do
      let(:rbac) { true }

      it { is_expected.to be_truthy }
    end

    context 'rbac is not enabled' do
      let(:rbac) { false }

      it { is_expected.to be_falsey }
    end
  end

  describe '#pod_name' do
    it 'returns the pod name' do
      expect(subject.pod_name).to eq("upgrade-app-name")
    end
  end
end
