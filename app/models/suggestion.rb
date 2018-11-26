class Suggestion < ApplicationRecord
  belongs_to :note

  def from_line
    position_new_line
  end

  def to_line
    position_new_line
  end

  def appliable?
    !applied? &&
      note.active? &&
      different_content? &&
      !original_lines_changed?
  end

  private

  def different_content?
    suggestion.split("\n") != current_changing_lines
  end

  def original_lines_changed?
    changing.split("\n") != current_changing_lines
  end

  def current_changing_lines
    from_index = from_line - 1
    to_index = to_line - 1

    new_blob_lines[from_index..to_index]
  end

  def new_blob_lines
    @new_blob_lines ||= note.diff_file.new_blob.lines
  end

  def position_new_line
    note.position.new_line
  end
end
