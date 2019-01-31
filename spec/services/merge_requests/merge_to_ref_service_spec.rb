require 'spec_helper'

describe MergeRequests::MergeToRefService do
  set(:user) { create(:user) }
  let(:merge_request) { create(:merge_request, :simple) }
  let(:project) { merge_request.project }

  before do
    project.add_maintainer(user)
  end

  describe '#execute' do
    let(:service) do
      described_class.new(project, user,
                          commit_message: 'Awesome message',
                          'should_remove_source_branch' => true)
    end

    def process_dry_merge
      perform_enqueued_jobs do
        service.execute(merge_request)
      end
    end

    it 'writes commit to merge ref' do
      repository = project.repository
      target_ref = merge_request.merge_ref_path

      expect(repository.ref_exists?(target_ref)).to be(false)

      result = service.execute(merge_request)

      ref_head = repository.commit(target_ref)

      expect(result[:status]).to eq(:success)
      expect(result[:commit_id]).to be_present
      expect(repository.ref_exists?(target_ref)).to be(true)
      expect(ref_head.id).to eq(result[:commit_id])
    end

    it 'does not send any mail' do
      expect { process_dry_merge }.not_to change { ActionMailer::Base.deliveries.count }
    end

    it 'does not change the MR state' do
      expect { process_dry_merge }.not_to change { merge_request.state }
    end

    it 'does not create notes' do
      expect { process_dry_merge }.not_to change { merge_request.notes.count }
    end

    it 'does not delete the source branch' do
      expect(DeleteBranchService).not_to receive(:new)

      process_dry_merge
    end

    it 'returns an error when the failing to process the merge' do
      allow(project.repository).to receive(:merge_to_ref).and_return(nil)

      result = service.execute(merge_request)

      expect(result[:status]).to eq(:error)
      expect(result[:message]).to eq('Conflicts detected during merge')
    end

    context 'commit history comparison with regular MergeService' do
      shared_examples_for 'MergeService for target ref' do
        it 'target_ref has the same state of target branch' do
          repo = merge_request.target_project.repository

          process_dry_merge
          merge_service.execute(merge_request)

          ref_commits = repo.commits(merge_request.merge_ref_path, limit: 3)
          target_branch_commits = repo.commits(merge_request.target_branch, limit: 3)

          ref_commits.zip(target_branch_commits).each do |ref_commit, target_branch_commit|
            expect(ref_commit.parents).to eq(target_branch_commit.parents)
          end
        end
      end

      let(:merge_ref_service) do
        described_class.new(project, user, {})
      end

      let(:merge_service) do
        MergeRequests::MergeService.new(project, user, {})
      end

      context 'when merge commit' do
        it_behaves_like 'MergeService for target ref'
      end

      context 'when merge commit with squash' do
        before do
          merge_request.update!(squash: true, source_branch: 'master', target_branch: 'feature')
        end

        it_behaves_like 'MergeService for target ref'
      end
    end

    context 'when fast-forward merge is not allowed' do
      %w(semi-linear ff).each do |merge_method|
        before do
          merge_method = 'rebase_merge' if merge_method == 'semi-linear'
          merge_request.project.update(merge_method: merge_method)
        end

        it "when merge is possible via #{merge_method}" do
          allow(merge_request).to receive(:ff_merge_possible?) { true }
          error = "Fast-forward to refs/merge-requests/#{merge_request.iid}/merge is currently not supported."

          result = service.execute(merge_request)

          expect(result[:status]).to eq(:error)
          expect(result[:message]).to eq(error)
        end

        it "logs and saves error if merge is #{merge_method} only" do
          allow(merge_request).to receive(:ff_merge_possible?) { false }
          error_message = 'Only fast-forward merge is allowed for your project. Please update your source branch'
          allow(service).to receive(:execute_hooks)

          result = service.execute(merge_request)

          expect(result[:status]).to eq(:error)
          expect(result[:message]).to eq(error_message)
        end
      end
    end

    context 'does not close related todos' do
      let(:merge_request) { create(:merge_request, assignee: user, author: user) }
      let(:project) { merge_request.project }
      let!(:todo) do
        create(:todo, :assigned,
               project: project,
               author: user,
               user: user,
               target: merge_request)
      end

      before do
        allow(service).to receive(:execute_hooks)

        perform_enqueued_jobs do
          service.execute(merge_request)
          todo.reload
        end
      end

      it { expect(todo).not_to be_done }
    end
  end
end
