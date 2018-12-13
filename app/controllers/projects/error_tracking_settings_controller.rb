# frozen_string_literal: true

class Projects::ErrorTrackingSettingsController < Projects::ApplicationController
  before_action :check_feature_flag!

  def show
  end

  def update
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
end
