# frozen_string_literal: true

class Projects::ErrorTrackingController < Projects::ApplicationController
  before_action :check_feature_flag!
  before_action :authorize_read_environment!
  before_action :push_feature_flag_to_frontend

  def list
  end

  def index
    external_url, errors = errors_for(@project)

    render json: {
      external_url: external_url,
      errors: errors
    }
  end

  private

  def errors_for(project)
    setting = setting_for(project)
    return nil, [] unless setting

    service = ErrorTracking::SentryIssuesService
      .new(setting.api_url, setting.token)
    errors = service.execute

    [service.external_url, errors]
  end

  def setting_for(project)
    setting = project.error_tracking_setting

    setting if setting&.enabled?
  end

  def check_feature_flag!
    render_404 unless Feature.enabled?(:error_tracking, project)
  end

  def push_feature_flag_to_frontend
    push_frontend_feature_flag(:error_tracking, current_user)
  end
end
