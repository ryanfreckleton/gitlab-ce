# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddBuildAnnotations < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  def change
    create_table(:ci_build_annotations, id: :bigserial) do |t|
      t.integer :build_id, null: false, index: true
      t.integer :severity, limit: 2, null: false

      # We use a smallint for line numbers as a maximum value of 32 767 should
      # be more than sufficient.
      t.integer :line_number, limit: 2

      # The path to the file the check belongs to, if any.
      t.text :file_path

      # We may end up displaying multiple summaries on a page. If these do not
      # have any limitations on the length, this may result in very big pages.
      # To prevent this from happening we enforce a more than reasonable limit
      # of 512 characters.
      t.string :summary, limit: 512, null: false

      t.text :description

      t.foreign_key :ci_builds, column: :build_id, on_delete: :cascade
    end
  end
end
