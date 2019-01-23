# frozen_string_literal: true

module ObjectPool
  class LeaveWorker
    include ApplicationWorker
    include ObjectPoolQueue
    include ExclusiveLeaseGuard

    sidekiq_options retry: 5, dead: true

    attr_reader :project
    attr_reader :original_visibility_level

    def perform(project_id, pool_id, visibility_level, original_visibility_level)
      @project = Project.find_by_id(project_id)
      @original_visibility_level = original_visibility_level
      Projects::LeaveRepositoryService.new(project, project.owner, pool_id: pool_id, reduplicate: true, visibility_level: visibility_level).execute
    end

    # if we fail to reduplicate and leave, roll back to the previous visibility level
    sidekiq_retries_exhausted do |msg|
      project.visibility_level = original_visibility_level
      project.visibility_changing = false
      project.save!
    end
  end
end
