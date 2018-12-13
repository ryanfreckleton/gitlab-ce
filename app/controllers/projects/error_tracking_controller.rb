# frozen_string_literal: true

class Projects::ErrorTrackingController < Projects::ApplicationController
  before_action :check_feature_flag!

  def list
  end

  def index
    render json: query_errors
  end

  def update_settings
    if error_tracking_setting.valid?
      respond_to do |format|
        format.json do
          head :no_content
        end
        format.html do
          flash[:notice] = _('Error tracking was successfully updated.')
          redirect_to error_tracking.show_path
        end
      end
    else
      respond_to do |format|
        format.json { head :bad_request }
        format.html { render :show }
      end
    end
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
