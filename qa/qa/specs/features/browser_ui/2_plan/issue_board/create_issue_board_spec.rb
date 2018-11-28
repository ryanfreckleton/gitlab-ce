# frozen_string_literal: true

module QA
  context 'Plan', :smoke do
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
          expect(show_page.list_count).to eq(2)

          # Delete List
          show_page.delete_list
          expect(show_page.list_count).to eq(1)

          # Add List
          show_page.add_list
          expect(show_page.list_count).to eq(2)

          # Drag and Drop Issue to List
          show_page.drag_and_drop_issue(0)
          expect(show_page.issue_card_count_per_list(0)).to eq(1)
          expect(show_page.issue_card_count_per_list(1)).to eq(0)

          show_page.drag_and_drop_issue(1)
          expect(show_page.issue_card_count_per_list(1)).to eq(1)
        end
      end
    end
  end
end
