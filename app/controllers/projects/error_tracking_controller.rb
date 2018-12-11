# frozen_string_literal: true

class Projects::ErrorTrackingController < Projects::ApplicationController
  before_action :check_feature_flag!

  def list
  end

  def index
    render json: []
  end

  private

  def check_feature_flag!
    render_404 unless Feature.enabled?(:error_tracking, project)
  end
end
