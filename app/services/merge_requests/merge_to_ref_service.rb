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
      unless merge_method_supported?
        raise MergeError, "#{project.human_merge_method} to " \
          "#{target_ref} is currently not supported."
      end

      commit_id = commit

      raise MergeError, 'Conflicts detected during merge' unless commit_id

      success(commit_id: commit_id)
    end

    def target_ref
      merge_request.merge_ref_path
    end

    def commit
      repository.merge_to_ref(current_user, source, merge_request, target_ref)
    rescue Gitlab::Git::PreReceiveError => e
      handle_merge_error(log_message: e.message)
    end

    def merge_method_supported?
      [:merge, :rebase_merge].include?(project.merge_method)
    end
  end
end
