# frozen_string_literal: true

module Files
  class UpdateService < Files::BaseService
    PatchUpdateError = Class.new(StandardError)

    def create_commit!
      if apply_as_patch?
        @file_content = apply_content_as_patch
      end

      repository.update_file(current_user, @file_path, @file_content,
                             message: @commit_message,
                             branch_name: @branch_name,
                             previous_path: @previous_path,
                             author_email: @author_email,
                             author_name: @author_name,
                             start_project: @start_project,
                             start_branch_name: @start_branch)
    end

    private

    def apply_content_as_patch
      from = @from_line - 1
      to = @to_line - 1
      content = branch_blob.data.lines
      content[from..to] = @file_content

      content.join
    end

    def validate!
      super

      if file_has_changed?(@file_path, @last_commit_sha)
        raise FileChangedError, "You are attempting to update a file that has changed since you started editing it."
      end

      if apply_as_patch?
        raise_patch_error('Invalid range.') unless @from_line.positive? && @from_line.positive? && @to_line >= @from_line
        raise_patch_error('Blob not found.') unless branch_blob
        raise_patch_error('Given line surpasses the scope of the file.') if @to_line > branch_blob.lines.size
      end
    end

    def apply_as_patch?
      @from_line && @to_line
    end

    def raise_patch_error(message)
      raise PatchUpdateError, message
    end

    def branch_blob
      @branch_blob ||= @start_project.repository.blob_at_branch(@branch_name, @file_path)
    end
  end
end
