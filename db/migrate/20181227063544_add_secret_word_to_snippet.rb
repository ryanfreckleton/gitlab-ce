# frozen_string_literal: true

class AddSecretWordToSnippet < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    add_column :snippets, :secret_word, :string
  end
end
