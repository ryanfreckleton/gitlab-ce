# frozen_string_literal: true

module API
  class ProjectTraffics < Grape::API
    before do
      authenticate!
      authorize! :push_code, user_project
    end

    params do
      requires :id, type: String, desc: 'The ID of a project'
    end
    resource :projects, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      desc 'Get the list of project fetch statistics for the last 30 days'
      get ":id/traffic/fetches" do
        finder = ProjectDailyStatisticsFinder.new(user_project)

        present :total_fetches, finder.total_fetch_count
        present :fetches, finder.fetches, with: Entities::ProjectDailyStatistic
      end
    end
  end
end
