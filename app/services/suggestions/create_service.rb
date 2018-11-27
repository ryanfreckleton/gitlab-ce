# frozen_string_literal: true

module Suggestions
  class CreateService
    def initialize(diff_note)
      @diff_note = diff_note
    end

    def execute
      return unless should_try_creation?

      suggestions = Banzai::SuggestionsParser.parse(@diff_note.note)

      # For single line suggestion we're only looking forward to
      # change the line receiving the comment. Though, in
      # https://gitlab.com/gitlab-org/gitlab-ce/issues/53310
      # we'll introduce a ```suggestion:L<x>-<y>, so this will
      # slightly change.
      comment_line = @diff_note.position.new_line

      rows =
        suggestions.map.with_index do |suggestion, index|
          from_content = changing_lines(comment_line, comment_line)
          to_content = suggestion

          {
            diff_note_id: @diff_note.id,
            changing: with_break_line(from_content),
            suggestion: with_break_line(to_content),
            relative_order: index
          }
        end

      Gitlab::Database.bulk_insert('suggestions', rows)
    end

    private

    def should_try_creation?
      @diff_note.on_text? && @diff_note.new_blob.present?
    end

    def changing_lines(from_line, to_line)
      @diff_note.diff_file.new_blob_lines_between(from_line, to_line).join("\n")
    end

    def with_break_line(lines)
      lines.ends_with?("\n") ? lines : "#{lines}\n"
    end
  end
end
