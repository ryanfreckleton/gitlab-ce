# frozen_string_literal: true

class Projects::ErrorTrackingController < Projects::ApplicationController
  before_action :check_feature_flag!

  def list
  end

  def index
    render json: [
      {
          "id": 2,
          "first_seen": "2018-11-06T21:19:56Z",
          "last_seen": "2018-11-06T21:19:56Z",
          "type": "ApiException",
          "message": "Authentication failed, token expired!",
          "culprit": "io.sentry.example.ApiRequest in perform",
          "count": 1,
          "external_url": "https://sentry.io/the-interstellar-jurisdiction/pump-station/issues/2/",
          "project": {
            "id": "2",
            "name": "Pump Station",
            "slug": "pump-station"
          },
          "short_id": "PUMP-STATION-2",
          "status": "unresolved",
          "status_details": {},
          "title": "ApiException: Authentication failed, token expired!",
          "type": "error",
          "user_count": 0
      },
      {
          "id": 3,
          "first_seen": "2018-10-06T21:19:56Z",
          "last_seen": "2018-11-06T21:19:56Z",
          "type": "BigError",
          "message": "All the things failed.",
          "culprit": "system.tasks.do.things",
          "count": 3,
          "external_url": "https://sentry.io/the-interstellar-jurisdiction/pump-station/issues/3/",
          "project": {
            "id": "2",
            "name": "Pump Station",
            "slug": "pump-station"
          },
          "short_id": "PUMP-STATION-3",
          "status": "unresolved",
          "status_details": {},
          "title": "BigError: All the things failed.",
          "type": "error",
          "user_count": 0
      },
    ]

  end

  private

  def check_feature_flag!
    render_404 unless Feature.enabled?(:error_tracking, project)
  end
end
