# frozen_string_literal: true

module Projects
  class LeaveRepositoryServiceFailure < StandardError
    attr_accessor :error_messgae

    def initialize(error_message = nil)
      @error_message = error_message
    end

    def success?
      error_message.empty?
    end

    def to_s
      success? ? "LeaveWorker Success" : "LeaveWorker Failed: #{error_message}"
    end
  end

  class LeaveRepositoryService < BaseService
    def execute
      # put project in read only mode
      raise LeaveRepositoryServiceFailure.new("reference count not 0") unless project.set_repository_read_only!

      pool = PoolRepository.find_by_id(params[:pool_id])
      pool.reduplicate(project.repository) if params[:reduplicate]

      pool.unlink_repository(project.repository)
      project.leave_pool_repository
      project.set_repository_writable!
      project.visibility_level = params[:visibility_level]
      project.visibility_level_changing = false
      project.save!
    end
  end
end
