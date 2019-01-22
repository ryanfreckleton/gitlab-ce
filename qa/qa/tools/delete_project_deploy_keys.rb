# frozen_string_literal: true

require_relative '../../qa'

# This script deletes all deploy keys for all project under subgroups of a group provided specified by ENV['GROUP_NAME_OR_PATH']
# Required environment variables: PERSONAL_ACCESS_TOKEN and GITLAB_ADDRESS
# Optional environment variable: GROUP_NAME_OR_PATH (defaults to 'gitlab-qa-sandbox-group')
# Run `rake delete_all_project_deploy_keys`

module QA
  module Tools
    class DeleteProjectDeployKeys
      include Support::Api

      def run
        raise ArgumentError, "Please provide GITLAB_ADDRESS" unless ENV['GITLAB_ADDRESS']
        raise ArgumentError, "Please provide PERSONAL_ACCESS_TOKEN" unless ENV['PERSONAL_ACCESS_TOKEN']

        STDOUT.puts 'Running...'

        # Fetch group's id
        api_client = Runtime::API::Client.new(ENV['GITLAB_ADDRESS'], personal_access_token: ENV['PERSONAL_ACCESS_TOKEN'])
        group_search_response = get Runtime::API::Request.new(api_client, "/groups", search: ENV['GROUP_NAME_OR_PATH'] || 'gitlab-qa-sandbox-group').url
        group_id = JSON.parse(group_search_response.body).first["id"]

        # Fetch all subgroups for the top level group
        next_sub_group_page = "1"
        while next_sub_group_page != ""
          sub_groups_response = get Runtime::API::Request.new(api_client, "/groups/#{group_id}/subgroups", per_page: "100", page: next_sub_group_page).url
          next_sub_group_page = sub_groups_response.headers[:x_next_page]

          sub_group_ids = JSON.parse(sub_groups_response.body).map { |subgroup| subgroup["id"] }

          # For each subgroup, fetch all projects
          sub_group_ids.each do |subgroup_id|
            next_project_page = "1"
            while next_project_page != ""
              project_response = get Runtime::API::Request.new(api_client, "/groups/#{subgroup_id}/projects", per_page: "100", page: next_project_page).url
              next_project_page = project_response.headers[:x_next_page]

              project_ids = JSON.parse(project_response.body).map { |project| project["id"] }

              # For each project, fetch all deploy keys
              project_ids.each do |project_id|
                next_deploy_key_page = "1"
                while next_deploy_key_page != ""
                  deploy_keys_response = get Runtime::API::Request.new(api_client, "/projects/#{project_id}/deploy_keys", per_page: "100", page: next_deploy_key_page).url
                  next_deploy_key_page = deploy_keys_response.headers[:x_next_page]

                  deploy_keys_ids = JSON.parse(deploy_keys_response.body).map { |deploy_key| deploy_key["id"] }

                  STDOUT.puts "project_id: #{project_id} deploy_keys_ids: #{deploy_keys_ids}"

                  # Delete each deploy key
                  deploy_keys_ids.each do |deploy_keys_id|
                    STDOUT.puts "Deleting deploy key with id: #{deploy_keys_id}"
                    delete Runtime::API::Request.new(api_client, "/projects/#{project_id}/deploy_keys/#{deploy_keys_id}").url
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
