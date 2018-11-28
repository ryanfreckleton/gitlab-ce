# frozen_string_literal: true

module Suggestions
  class ApplyService < ::BaseService
    def initialize(current_user)
      @current_user = current_user
    end

    def execute(suggestion)
      unless suggestion.appliable?
        return error('Suggestion is not appliable')
      end

      params = file_update_params(suggestion)

      result = ::Files::UpdateService.new(suggestion.project, @current_user, params).execute

      suggestion.update(applied: true) if result[:status] == :success

      result
    end

    private

    def file_update_params(suggestion)
      diff_file = suggestion.diff_file

      file_path = diff_file.file_path
      branch_name = suggestion.noteable.source_branch
      file_content = new_file_content(suggestion)
      author_email = @current_user.commit_email
      author_name = @current_user.name
      commit_message = "Applies suggestion to #{file_path}"

      {
        file_path: file_path,
        branch_name: branch_name,
        start_branch: branch_name,
        commit_message: commit_message,
        file_content: file_content,
        author_email: author_email,
        author_name: author_name
      }
    end

    def new_file_content(suggestion)
      range = suggestion.from_line_index..suggestion.to_line_index
      blob = suggestion.diff_file.new_blob
      content = blob.data.lines
      content[range] = suggestion.suggestion

      content.join
    end
  end
end
