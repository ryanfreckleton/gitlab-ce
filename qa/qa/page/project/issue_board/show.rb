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

          def delete_list(issue_board_title)
            within(find_element(:issue_board, issue_board_title)) do
              accept_alert do
                click_element(:delete_board_button)
              end
            end
          end

          def add_list
            click_element :add_list_button
            click_element :inactive_board
          end

          def drag_and_drop_issue(issue_title, issue_board_title)
            draggable = find_element(:board_card, issue_title)
            droppable = find_element(:issue_board, issue_board_title)
            draggable.drag_to(droppable)
          end

          def card_present_in_board?(issue_title, issue_board_title)
            board_text = find_element(:issue_board, issue_board_title).text
            board_text.include?(issue_title)
          end
        end
      end
    end
  end
end
