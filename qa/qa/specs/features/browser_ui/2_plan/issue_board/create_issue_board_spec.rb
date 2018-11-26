# frozen_string_literal: true

module QA
  context 'Plan', :smoke do
    describe 'Issue Board creation' do
      it 'user creates an issue' do
        Runtime::Browser.visit(:gitlab, Page::Main::Login)
        Page::Main::Login.act { sign_in_using_credentials }

        Resource::IssueBoard.fabricate! do |issue_board|
          issue_board.issues_count = 2
        end

        Page::Project::Menu.act { click_issues }

        expect(page).to have_content(issue_title)
      end
    end
  end
end
