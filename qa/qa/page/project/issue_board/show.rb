# frozen_string_literal: true

module QA
  module Page
    module Project
      module IssueBoard
        class Show < Page::Base
          view 'app/assets/javascripts/boards/components/board_blank_state.vue' do
            element :default_lists_button
          end

          view 'app/views/shared/boards/components/_board.html.haml' do
            element :delete_board_button
            element :issue_board
          end

          view 'app/views/shared/issuable/_board_create_list_dropdown.html.haml' do
            element :add_list_button
          end

          view 'app/assets/javascripts/boards/components/new_list_dropdown.js' do
            element :inactive_board
          end

          view 'app/assets/javascripts/boards/components/board_card.vue' do
            element :board_card
          end

          def create_default_lists
            sleep 10
            click_element :default_lists_button
          end

          def delete_list
            accept_alert do
              all_elements(:delete_board_button).first.click
            end
          end

          def add_list
            click_element :add_list_button
            click_element :inactive_board
          end

          def list_count
            using_wait_time(Capybara.default_max_wait_time) do
              all_elements(:issue_board).count
            end
          end

          def drag_and_drop_issue(issue_list_id = 0)
            draggable = all_elements(:board_card).first
            droppable = all_elements(:issue_board)[issue_list_id]
            draggable.drag_to(droppable)
          end

          def issue_card_count_per_list(issue_list_id = 0)
            within(all_elements(:issue_board)[issue_list_id]) do
              all_elements(:board_card).count
            end
          end
        end
      end
    end
  end
end
