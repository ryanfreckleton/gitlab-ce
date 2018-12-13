# frozen_string_literal: true

module ErrorTracking
  class ErrorTrackingSetting < ActiveRecord::Base
    include Presentable
    include Gitlab::Utils::StrongMemoize

    self.table_name = 'error_tracking_settings'

    belongs_to :project

    attr_encrypted :token,
      mode: :per_attribute_iv,
      key: Settings.attr_encrypted_db_key_base_truncated,
      algorithm: 'aes-256-gcm'
  end
end
