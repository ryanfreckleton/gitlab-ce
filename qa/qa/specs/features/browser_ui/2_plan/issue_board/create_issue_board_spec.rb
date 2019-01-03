# frozen_string_literal: true

module QA
  context 'Plan' do
    describe 'Issue Board creation' do
      it 'user creates an issue board' do
        Runtime::Browser.visit(:gitlab, Page::Main::Login)
        Page::Main::Login.perform(&:sign_in_using_credentials)

        Resource::IssueBoard.fabricate! do |issue_board|
          issue_board.issues = [{ title: "My Issue 1", description: "My Desc 1" },
                                { title: "My Issue 2", description: "My Desc 2" }]
        end

        # Visit Blank Board
        Page::Project::Menu.perform(&:go_to_boards)

        Page::Project::IssueBoard::Show.perform do |show_page|
          # Create Default Lists
          show_page.create_default_lists
          expect(show_page).to have_content("Doing")
          expect(show_page).to have_content("To Do")

          # Delete List
          show_page.delete_list("To Do")
          expect(show_page).not_to have_content("To Do")

          # Add List
          show_page.add_list
          expect(show_page).to have_content("To Do")

          # Drag and Drop Issue to List
          show_page.drag_and_drop_issue("My Issue 2", "Doing")
          expect(show_page.card_present_in_board?("My Issue 2", "Doing")).to be true
          expect(show_page.card_present_in_board?("My Issue 1", "To Do")).to be false
        end
      end
    end
  end
end
