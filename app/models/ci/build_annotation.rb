# frozen_string_literal: true

module Ci
  class BuildAnnotation < ActiveRecord::Base
    self.table_name = 'ci_build_annotations'

    belongs_to :build, class_name: 'Ci::Build', foreign_key: :build_id

    enum severity: {
      info: 0,
      warning: 1,
      error: 2
    }

    # We deliberately validate just the presence of the ID, and not the target
    # row. We do this for two reasons:
    #
    # 1. Foreign key checks already ensure the ID points to a valid row.
    #
    # 2. When parsing artifacts, we run validations for every row to make sure
    #    they are in the correct format. Validating an association would result
    #    in a database query being executed for every entry, slowing down the
    #    parsing process.
    validates :build_id, presence: true

    validates :severity, presence: true
    validates :summary, presence: true, length: { maximum: 512 }

    validates :line_number,
      numericality: {
        greater_than_or_equal_to: 1,
        less_than_or_equal_to: 32767,
        only_integer: true
      },
      allow_nil: true

    # Only giving a file path or line number makes no sense, so if either is
    # given we require both to be present.
    validates :line_number, presence: true, if: :file_path?
    validates :file_path, presence: true, if: :line_number?
  end
end
