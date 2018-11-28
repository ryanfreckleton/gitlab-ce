# frozen_string_literal: true

class Suggestion < ApplicationRecord
  belongs_to :diff_note, inverse_of: :suggestions
  validates :diff_note, presence: true

  delegate :project, :position, :diff_file, :noteable, to: :diff_note

  def from_line
    position.new_line
  end
  alias_method :to_line, :from_line

  # `from_line_index` and `to_line_index` represents diff/blob line numbers in
  # index-like way (N-1).
  def from_line_index
    from_line - 1
  end
  alias_method :to_line_index, :from_line_index

  def appliable?
    !applied? &&
      diff_note.active? &&
      diff_file.new_blob &&
      different_content? &&
      !original_lines_changed?
  end

  private

  def different_content?
    suggestion.lines != current_changing_lines
  end

  def original_lines_changed?
    changing.lines != current_changing_lines
  end

  def current_changing_lines
    @current_changing_lines ||=
      diff_file.new_blob_lines_between(from_line, to_line)
  end
end
