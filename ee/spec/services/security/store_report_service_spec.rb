# frozen_string_literal: true

require 'spec_helper'

describe Security::StoreReportService, '#execute' do
  let(:artifact) { create(:ee_ci_job_artifact, :sast) }
  let(:project) { artifact.project }
  let(:pipeline) { artifact.job.pipeline }
  let(:report) { pipeline.security_reports.get_report('sast') }

  before do
    stub_licensed_features(sast: true)
  end

  subject { described_class.new(pipeline, report).execute }

  context 'without existing data' do
    it 'inserts all scanners' do
      expect { subject }.to change { Vulnerabilities::Scanner.count }.by(3)
    end

    it 'inserts all identifiers' do
      expect { subject }.to change { Vulnerabilities::Identifier.count }.by(4)
    end

    it 'inserts all occurrences' do
      expect { subject }.to change { Vulnerabilities::Occurrence.count }.by(3)
    end

    it 'inserts all occurrence identifiers (join model)' do
      expect { subject }.to change { Vulnerabilities::OccurrenceIdentifier.count }.by(5)
    end

    it 'inserts all occurrence pipelines (join model)' do
      expect { subject }.to change { Vulnerabilities::OccurrencePipeline.count }.by(3)
    end
  end

  context 'with existing data from previous pipeline' do
    let(:scanner) { create(:vulnerabilities_scanner, project: project, external_id: 'find_sec_bugs', name: 'existing_name') }
    let(:identifier) { create(:vulnerabilities_identifier, project: project, fingerprint: 'f5724386167705667ae25a1390c0a516020690ba') }
    let!(:new_artifact) { create(:ee_ci_job_artifact, :sast, job: new_build) }
    let(:new_build) { create(:ci_build, pipeline: new_pipeline) }
    let(:new_pipeline) { create(:ci_pipeline, project: project) }
    let(:new_report) { new_pipeline.security_reports.get_report('sast') }

    let!(:occurrence) do
      create(:vulnerabilities_occurrence,
        pipelines: [pipeline],
        identifiers: [identifier],
        primary_identifier: identifier,
        scanner: scanner,
        project: project,
        location_fingerprint: '6b6bb283d43cc510d7d1e73e2882b3652cb34bd5')
    end

    subject { described_class.new(new_pipeline, new_report).execute }

    it 'inserts only new scanners and reuse existing ones' do
      expect { subject }.to change { Vulnerabilities::Scanner.count }.by(2)
    end

    it 'inserts only new identifiers and reuse existing ones' do
      expect { subject }.to change { Vulnerabilities::Identifier.count }.by(3)
    end

    it 'inserts only new occurrences and reuse existing ones' do
      expect { subject }.to change { Vulnerabilities::Occurrence.count }.by(2)
    end

    it 'inserts all occurrence pipelines (join model) for this new pipeline' do
      expect { subject }.to change { Vulnerabilities::OccurrencePipeline.where(pipeline: new_pipeline).count }.by(3)
    end
  end

  context 'with existing data from same pipeline' do
    let!(:occurrence) { create(:vulnerabilities_occurrence, project: project, pipelines: [pipeline]) }

    it 'skips report' do
      expect(subject).to eq({
        status: :error,
        message: "sast report already stored for this pipeline, skipping..."
      })
    end
  end
end