# frozen_string_literal: true

module Projects
  module Settings
    class OperationsController < Projects::ApplicationController
      before_action :check_license
      before_action :authorize_update_environment!

      helper_method :error_tracking_setting

      def show
      end

      def update
        result = ::Projects::Operations::UpdateService.new(project, current_user, update_params).execute

        respond_to do |format|
          format.json do
            if result[:status] == :success
              render json:
                result.slice(:status).merge({
                message: _('Your changes have been saved')
              })
            else
              render(
                status: result[:http_status] || :bad_request,
                json: result.slice(:status, :message)
              )
            end
          end
        end
      end

      private

      def error_tracking_setting
        @error_tracking_setting ||= project.error_tracking_setting ||
          project.build_error_tracking_setting
      end

      def update_params
        params.require(:project).permit(permitted_project_params)
      end

      # overridden in EE
      def permitted_project_params
        {
          error_tracking_setting_attributes: [
            :enabled,
            :api_host,
            :token,
            project: [:slug, :name, :organization_slug, :organization_name]
          ]
        }
      end

      def check_license
        render_404 unless helpers.settings_operations_available?
      end
    end
  end
end
