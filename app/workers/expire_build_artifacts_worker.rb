# frozen_string_literal: true

class ExpireBuildArtifactsWorker
  include ApplicationWorker
  include CronjobQueue

  REMOVAL_SIDEKIQ_JOBS_LIMIT = 1000

  # rubocop: disable CodeReuse/ActiveRecord
  def perform
    Rails.logger.info 'Scheduling removal of build artifacts'

    total_removal_sidekiq_job_count = 0

    Ci::Build.with_expired_artifacts
             .include(EachBatch)
             .each_batch(of: 100) do |relation, index|
      build_ids = relation.pluck(:id)
      build_ids = build_ids.map { |build_id| [build_id] }

      ExpireBuildInstanceArtifactsWorker.bulk_perform_async(build_ids)

      total_removal_sidekiq_job_count += build_ids.count

      ##
      # The number of expired artifacts could be very huge with the gitlab.com scale.
      # In order to remove artifacts gracefully even in such an environment,
      # this cron worker schedules only the specific amount of sidekiq jobs.
      break if total_removal_sidekiq_job_count >= REMOVAL_SIDEKIQ_JOBS_LIMIT
    end
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
