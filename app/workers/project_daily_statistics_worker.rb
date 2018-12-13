# frozen_string_literal: true

class ProjectDailyStatisticsWorker
  include ApplicationWorker

  # rubocop: disable CodeReuse/ActiveRecord
  def perform(project_id)
    project = Project.find_by(id: project_id)

    return unless project && project.repository.exists?

    Projects::FetchStatisticsIncrementService.new(project).execute
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
