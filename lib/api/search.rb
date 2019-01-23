# frozen_string_literal: true

module API
  class Search < Grape::API
    include PaginationParams

    before { authenticate! }

    helpers do
      SCOPE_ENTITY = {
        merge_requests: Entities::MergeRequestBasic,
        issues: Entities::IssueBasic,
        projects: Entities::BasicProjectDetails,
        milestones: Entities::Milestone,
        notes: Entities::Note,
        commits: Entities::CommitDetail,
        blobs: Entities::Blob,
        wiki_blobs: Entities::Blob,
        snippet_titles: Entities::Snippet,
        snippet_blobs: Entities::Snippet,
        users: Entities::UserBasic
      }.freeze

      def search(additional_params = {})
        search_params = {
          scope: params[:scope],
          search: params[:search],
          snippets: snippets?,
          page: params[:page],
          per_page: params[:per_page]
        }.merge(additional_params)

        results = SearchService.new(current_user, search_params).search_objects

        process_results(results)
      end

      def process_results(results)
        paginate(results)
      end

      def snippets?
        %w(snippet_blobs snippet_titles).include?(params[:scope]).to_s
      end

      def entity
        SCOPE_ENTITY[params[:scope].to_sym]
      end

      params :scope do |options|
        scope_entities =
          if Feature.enabled?(:users_search, default_enabled: true)
            SCOPE_ENTITY
          else
            SCOPE_ENTITY.reject { |key, value| key == :users }
          end

        values = scope_entities.stringify_keys.slice(*options[:values]).keys

        requires :scope,
          type: String,
          desc: "The scope of search, available scopes: #{values.join(', ')}",
          values: values
      end
    end

    resource :search do
      desc 'Search on GitLab' do
        detail 'This feature was introduced in GitLab 10.5.'
      end
      params do
        requires :search, type: String, desc: 'The expression it should be searched for'
        use :scope, values: %w(projects issues merge_requests milestones snippet_titles snippet_blobs users)
        use :pagination
      end
      get do
        present search, with: entity
      end
    end

    resource :groups, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      desc 'Search on GitLab' do
        detail 'This feature was introduced in GitLab 10.5.'
      end
      params do
        requires :id, type: String, desc: 'The ID of a group'
        requires :search, type: String, desc: 'The expression it should be searched for'
        use :scope, values: %w(projects issues merge_requests milestones users)
        use :pagination
      end
      get ':id/(-/)search' do
        present search(group_id: user_group.id), with: entity
      end
    end

    resource :projects, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      desc 'Search on GitLab' do
        detail 'This feature was introduced in GitLab 10.5.'
      end
      params do
        requires :id, type: String, desc: 'The ID of a project'
        requires :search, type: String, desc: 'The expression it should be searched for'
        use :scope, values: %w(issues merge_requests milestones notes wiki_blobs commits blobs users)
        use :pagination
      end
      get ':id/(-/)search' do
        present search(project_id: user_project.id), with: entity
      end
    end
  end
end
