# frozen_string_literal: true

module Projects::ErrorTrackingHelper
  def error_tracking_data(project)
    {
      'index-path' => namespace_project_error_tracking_index_path(
        namespace_id: project.namespace,
        project_id: project
      )
    }
  end
end
