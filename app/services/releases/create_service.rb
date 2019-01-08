# frozen_string_literal: true

module Releases
  class CreateService < BaseService
    include Gitlab::Utils::StrongMemoize

    def execute
      return error('Access Denied', 403) unless allowed?
      return error('Release already exists', 409) if release

      tag = ensure_tag

      return tag unless tag.is_a?(Gitlab::Git::Tag)

      create_release(tag)
    end

    private

    def ensure_tag
      existing_tag || create_tag
    end

    def create_tag
      return error('Ref is not specified', 422) unless params[:ref]

      result = Tags::CreateService
        .new(project, current_user)
        .execute(params[:tag], ref, nil)

      return result unless result[:status] == :success

      result[:tag]
    end

    def allowed?
      Ability.allowed?(current_user, :create_release, project)
    end

    def create_release(tag)
      release = project.releases.create!(
        name: params[:name],
        description: params[:description],
        author: current_user,
        tag: tag.name,
        sha: tag.dereferenced_target.sha,
        links_attributes: params.dig(:assets, 'links') || []
      )

      success(tag: tag, release: release)
    rescue => e
      error(e.message, 400)
    end

    def release
      strong_memoize(:release) do
        project.releases.find_by_tag(tag_name)
      end
    end

    def existing_tag
      strong_memoize(:existing_tag) do
        project.repository.find_tag(tag_name)
      end
    end
  end
end
