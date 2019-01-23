# frozen_string_literal: true

require 'spec_helper'

describe ObjectPool::LeaveWorker do
  let(:pool) { create(:pool_repository, :ready) }
  let(:project) { pool.source_project }
  let(:repository) { project.repository }

  subject { described_class.new }

  before do
    pool.link_repository(repository)
  end

  describe '#perform' do
    context 'when the git repo is not being written to' do
      it "doesn't raise an error" do
        expect do
          subject.perform(project, pool.id, Gitlab::VisibilityLevel::PRIVATE, Gitlab::VisibilityLevel::PUBLIC)
        end.not_to raise_error
      end
    end

    context 'when the git repo is being written to' do
      before do
        project.reference_counter.increase
      end

      it "fails when trying to leave the pool" do
        expect do
          subject.perform(project.id, pool.id, Gitlab::VisibilityLevel::PRIVATE, Gitlab::VisibilityLevel::PUBLIC)
        end.to raise_error(Projects::LeaveRepositoryServiceFailure)
      end
    end
  end
end
