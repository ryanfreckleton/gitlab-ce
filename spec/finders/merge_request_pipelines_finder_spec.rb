# frozen_string_literal: true

require 'spec_helper'

describe MergeRequestPipelinesFinder do
  let(:merge_request) { create(:merge_request, :conflict) }

  before do
    create_list(:ci_pipeline, 2, :auto_devops_source, project: merge_request.source_project, sha: merge_request.diff_head_sha, ref: merge_request.source_branch)
    create(:ci_pipeline, :repository_source, project: merge_request.source_project, sha: merge_request.all_commit_shas.last, ref: merge_request.source_branch)
    create_list(:ci_pipeline, 2, project: merge_request.source_project, sha: merge_request.diff_head_sha)
  end

  describe "#execute" do
    it 'filters by sha' do
      params = { sha: merge_request.diff_head_sha }

      pipelines = described_class.new(merge_request, params).execute

      expect(pipelines.size).to eq(2)
    end

    it 'with source_branch ref as the pipeline ref by default' do
      pipelines = described_class.new(merge_request).execute

      expect(pipelines.size).to eq(3)
    end
  end
end
