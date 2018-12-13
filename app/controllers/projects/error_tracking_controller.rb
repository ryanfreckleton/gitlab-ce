# frozen_string_literal: true

class Projects::ErrorTrackingController < Projects::ApplicationController
  before_action :check_feature_flag!

  def list
  end

  def index
    render json: query_errors
  end

  private

  def query_errors
    setting = fetch_settings(@project)
    return [] unless setting

    ErrorTracking::SentryIssuesService
      .new(setting.uri, setting.token)
      .execute
  end

  def fetch_settings(project)
    setting = project.error_tracking_setting
    return setting if setting&.enabled?
  end

  def check_feature_flag!
    render_404 unless Feature.enabled?(:error_tracking, project)
  end
end
