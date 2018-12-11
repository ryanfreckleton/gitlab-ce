# frozen_string_literal: true

class Projects::ErrorTrackingController < Projects::ApplicationController
  def list
  end

  def index
    render json: []
  end
end
