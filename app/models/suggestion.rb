# frozen_string_literal: true

class Suggestion < ApplicationRecord
  belongs_to :diff_note, inverse_of: :suggestions
  validates :diff_note, presence: true

  delegate :project, to: :diff_note
  delegate :position, to: :diff_note
  delegate :diff_file, to: :diff_note

  def from_line
    position.new_line
  end

  def to_line
    position.new_line
  end

  def appliable?
    !applied? &&
      diff_note.active? &&
      diff_file.new_blob.present? &&
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
    @current_changing_lines ||=
      diff_file.new_blob_lines_between(from_line, to_line)
  end
end
