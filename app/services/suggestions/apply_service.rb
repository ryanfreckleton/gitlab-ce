# frozen_string_literal: true

module Suggestions
  class ApplyService < ::BaseService
    PatchError = Class.new(StandardError)

    def initialize(current_user)
      @current_user = current_user
    end

    def execute(suggestion)
      unless suggestion.appliable?
        return error('Suggestion is not appliable')
      end

      diff_note = suggestion.note
      diff_file = diff_note.diff_file

      file_path = diff_file.file_path
      branch_name = diff_note.noteable.source_branch
      file_content = new_file_content(suggestion, diff_file)
      author_email = @current_user.email
      author_name = @current_user.name
      commit_message = "Applies suggestion to #{file_path}"

      params = {
        file_path: file_path,
        branch_name: branch_name,
        start_branch: branch_name,
        commit_message: commit_message,
        file_content: file_content,
        author_email: author_email,
        author_name: author_name
      }

      result = ::Files::UpdateService.new(diff_note.project, @current_user, params).execute

      suggestion.update(applied: true) if result[:status] == :success

      result
    end

    private

    def new_file_content(suggestion, diff_file)
      from_index = suggestion.from_line - 1
      to_index = suggestion.to_line - 1
      blob = diff_file.new_blob

      content = blob.data.lines
      content[from_index..to_index] = suggestion.suggestion

      content.join
    end
  end
end
