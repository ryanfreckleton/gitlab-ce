# frozen_string_literal: true
require 'uri'

module QA
  module Page
    module Project
      module Issue
        class Show < Page::Base
          include Page::Component::Issuable::Common

          view 'app/views/shared/notes/_form.html.haml' do
            element :new_note_form, 'new-note' # rubocop:disable QA/ElementWithPattern
            element :new_note_form, 'attr: :note' # rubocop:disable QA/ElementWithPattern
          end

          view 'app/assets/javascripts/notes/components/comment_form.vue' do
            element :comment_button
            element :comment_input
          end

          view 'app/assets/javascripts/notes/components/discussion_filter.vue' do
            element :discussion_filter
            element :filter_options
          end

          view 'app/assets/javascripts/notes/components/note_header.vue' do
            element :note_header
          end

          # Adds a comment to an issue
          # attachment option should be an absolute path
          def comment(text, attachment: nil)
            fill_element :comment_input, text

            unless attachment.nil?
              QA::Page::Component::Dropzone.new(self, '.new-note')
                  .attach_file(attachment)
            end

            click_element :comment_button
          end

          def select_comments_only_filter
            click_element :discussion_filter
            all_elements(:filter_options)[1].click
          end

          def select_history_only_filter
            click_element :discussion_filter
            all_elements(:filter_options).last.click
          end

          def select_all_activities_filter
            click_element :discussion_filter
            all_elements(:filter_options).first.click
          end

          def issue_id
            URI.parse(current_url).path.split('/').last
          end

          def first_note_header
            wait_for_notes_to_be_displayed
            all_elements(:note_header).first.text
          end

          private

          def wait_for_notes_to_be_displayed
            notes_found = wait(reload: false, max: 5) do
              all_elements(:note_header).count > 0
            end
            raise ElementNotFound, "Couldn't find any notes on the issue page" unless notes_found
          end
        end
      end
    end
  end
end
