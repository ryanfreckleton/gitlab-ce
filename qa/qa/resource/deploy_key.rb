# frozen_string_literal: true

module QA
  module Resource
    class DeployKey < Base
      attr_accessor :title, :key, :allow_write_access

      attribute :fingerprint do
        Page::Project::Settings::Repository.perform do |setting|
          setting.expand_deploy_keys do |key|
            key_offset = key.key_titles.index do |key_title|
              key_title.text == title
            end

            key.key_fingerprints[key_offset].text
          end
        end
      end

      attribute :project do
        Project.fabricate! do |resource|
          resource.name = 'project-to-deploy'
          resource.description = 'project for adding deploy key test'
        end
      end

      def fabricate!
        project.visit!

        Page::Project::Menu.perform(&:click_repository_settings)

        Page::Project::Settings::Repository.perform do |setting|
          setting.expand_deploy_keys do |page|
            page.fill_key_title(title)
            page.fill_key_value(key)
            page.allow_write_access if allow_write_access

            page.add_key
          end
        end
      end
    end
  end
end
