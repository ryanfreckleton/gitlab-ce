# frozen_string_literal: true

module Suggestions
  class CreateService
    def initialize(diff_note)
      @diff_note = diff_note
    end

    def execute
      suggestions = Banzai::SuggestionsParser.parse(@diff_note.note)

      # For single line suggestion we're only looking forward to
      # change the line receiving the comment. Though, in
      # https://gitlab.com/gitlab-org/gitlab-ce/issues/53310
      # we'll introduce a ```suggestion:L<x>-<y>, so this will
      # slightly change.
      comment_index = @diff_note.position.new_line - 1

      rows =
        suggestions.map.with_index do |suggestion, index|
          from_content = changing_lines(comment_index, comment_index)
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

    def with_break_line(lines)
      lines.ends_with?("\n") ? lines : "#{lines}\n"
    end

    def changing_lines(from_index, to_index)
      new_blob_lines[from_index..to_index].join("\n")
    end

    def new_blob_lines
      @new_blob_lines ||= @diff_note.diff_file.new_blob.lines
    end
  end
end
