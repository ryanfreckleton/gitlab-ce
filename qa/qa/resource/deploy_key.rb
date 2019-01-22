# frozen_string_literal: true

module QA
  module Resource
    class DeployKey < Base
      attr_accessor :title, :key

      attribute :fingerprint do
        Page::Project::Settings::Repository.perform do |setting|
          setting.expand_deploy_keys do |key|
            key.find_fingerprint(title)
          end
        end
      end

      attribute :project do
        Project.fabricate! do |resource|
          resource.name = 'project-to-deploy'
          resource.description = 'project for adding deploy key test'
        end
      end

      def remove_via_api!
        project_id = project.api_response[:id]

        api_client = Runtime::API::Client.new(:gitlab)
        deploy_keys_response = get Runtime::API::Request.new(api_client, "/projects/#{project_id}/deploy_keys").url

        deploy_key = JSON.parse(deploy_keys_response.body).find { |item| item["key"].strip == key.strip }

        if deploy_key
          delete Runtime::API::Request.new(api_client, "/projects/#{project_id}/deploy_keys/#{deploy_key["id"]}").url
        end
      end

      def fabricate!
        project.visit!

        Page::Project::Menu.perform(&:click_repository_settings)

        Page::Project::Settings::Repository.perform do |setting|
          setting.expand_deploy_keys do |page|
            page.fill_key_title(title)
            page.fill_key_value(key)

            page.add_key
          end
        end
      end
    end
  end
end
