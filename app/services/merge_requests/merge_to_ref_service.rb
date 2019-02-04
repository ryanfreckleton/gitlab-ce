# frozen_string_literal: true

module MergeRequests
  # Performs the merge between source SHA and the target branch. Instead
  # of writing the result to the MR target branch, it targets the `target_ref`.
  #
  # Ideally this should leave the `target_ref` state with the same state the
  # target branch would have if we used the regular `MergeService`, but without
  # every side-effect that comes with it (MR updates, mails, source branch
  # deletion, etc). This service should be kept idempotent (i.e. can
  # be executed regardless of the `target_ref` current state).
  #
  class MergeToRefService < MergeRequests::MergeService
    def execute(merge_request)
      @merge_request = merge_request

      error_check!

      process_merge
    rescue MergeError => error
      error(error.message)
    end

    private

    def process_merge
      commit_id = commit

      raise MergeError, 'Conflicts detected during merge' unless commit_id

      success(commit_id: commit_id)
    end

    def error_check!
      error =
        if !merge_method_supported?
          "#{project.human_merge_method} to #{target_ref} is currently not supported."
        elsif @merge_request.should_be_rebased?
          'Only fast-forward merge is allowed for your project. Please update your source branch'
        elsif !@merge_request.mergeable_to_ref?
          "Merge request is not mergeable to #{target_ref}"
        elsif !source
          'No source for merge'
        end

      raise MergeError, error if error
    end

    def target_ref
      merge_request.merge_ref_path
    end

    def commit
      repository.merge_to_ref(current_user, source, merge_request, target_ref)
    rescue Gitlab::Git::PreReceiveError => error
      raise MergeError, error.message
    end

    def merge_method_supported?
      [:merge, :rebase_merge].include?(project.merge_method)
    end
  end
end
