# frozen_string_literal: true

module ErrorTracking
  class ErrorTrackingSetting < ActiveRecord::Base
    belongs_to :project

    validates :api_url, length: { maximum: 255 }, public_url: true
    validates :token, presence: true

    before_validation :sanitize_api_url

    attr_encrypted :token,
      mode: :per_attribute_iv,
      key: Settings.attr_encrypted_db_key_base_truncated,
      algorithm: 'aes-256-gcm'

    def sanitize_api_url
      self.api_url = ActionController::Base.helpers.sanitize(self.api_url, tags: [])
    end
  end
end
