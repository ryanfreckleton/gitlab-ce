module QA
  module Page
    module Project
      module Settings
        class DeployKeys < Page::Base
          view 'app/views/projects/deploy_keys/_form.html.haml' do
            element :deploy_key_title, 'text_field :title' # rubocop:disable QA/ElementWithPattern
            element :deploy_key_key, 'text_area :key' # rubocop:disable QA/ElementWithPattern
            element :write_access_allowed_checkbox
          end

          view 'app/assets/javascripts/deploy_keys/components/app.vue' do
            element :deploy_keys_section, /class=".*deploy\-keys.*"/ # rubocop:disable QA/ElementWithPattern
            element :project_deploy_keys, 'class="qa-project-deploy-keys"' # rubocop:disable QA/ElementWithPattern
          end

          view 'app/assets/javascripts/deploy_keys/components/key.vue' do
            element :key_title, /class=".*qa-key-title.*"/ # rubocop:disable QA/ElementWithPattern
            element :key_fingerprint, /class=".*qa-key-fingerprint.*"/ # rubocop:disable QA/ElementWithPattern
          end

          def fill_key_title(title)
            fill_in 'deploy_key_title', with: title
          end

          def fill_key_value(key)
            fill_in 'deploy_key_key', with: key
          end

          def add_key
            click_on 'Add key'
          end

          def key_title
            within_project_deploy_keys do
              find_element(:key_title).text
            end
          end

          def key_fingerprint
            within_project_deploy_keys do
              find_element(:key_fingerprint).text
            end
          end

          def key_titles
            within_project_deploy_keys do
              all_elements(:key_title)
            end
          end

          def key_fingerprints
            within_project_deploy_keys do
              all_elements(:key_fingerprint)
            end
          end

          def allow_write_access
            check_element :write_access_allowed_checkbox
          end

          private

          def within_project_deploy_keys
            wait(reload: false) do
              has_css?(element_selector_css(:project_deploy_keys))
            end

            within_element(:project_deploy_keys) do
              yield
            end
          end
        end
      end
    end
  end
end
