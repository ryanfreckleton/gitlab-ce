# frozen_string_literal: true

module ErrorTracking
  class Error
    include ActiveModel::Model

    attr_accessor :id, :title, :type, :user_count, :count,
      :first_seen, :last_seen, :message, :culprit,
      :external_url, :project_id, :project_name, :project_slug,
      :short_id, :status

    attr_accessor :frequency
  end
end
