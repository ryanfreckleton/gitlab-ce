# frozen_string_literal: true

module QA
  context 'Plan' do
    let(:issue_title) {'issue to close'}

    describe 'Issues' do
      it 'closes the issue after pushing a commit' do
        Runtime::Browser.visit(:gitlab, Page::Main::Login)
        Page::Main::Login.act {sign_in_using_credentials}
        Resource::Issue.fabricate! do |issue|
          issue.title = issue_title
        end
        issue_id = Page::Project::Issue::Show.perform(&:issue_id)
        # It is necessary to initiate an initial commit - as the first push into a repository doesn't trigger the closing
        # https://gitlab.com/gitlab-org/gitlab-ce/issues/54722
        push_file("initial commit", "firstfile")

        push_file("Closes ##{issue_id}", "secondfile")
        commit_sha = Page::File::Show.perform(&:commit_sha)
        Page::Project::Menu.act {click_issues}
        Page::Project::Issue::Index.perform do |page|
          page.show_closed_issues
          page.go_to_issue(issue_title)
        end

        Page::Project::Issue::Show.perform do |page|
          expect(page.first_note_header).to have_content("@#{Runtime::User.username} closed via commit #{commit_sha}")
        end
      end

      def push_file(commit_message, filename)
        Page::Project::Menu.act {click_project}
        Page::Project::Show.act {create_new_file!}
        Page::File::Form.perform do |page|
          page.add_name(filename)
          page.add_content('Lorem ipsum dolor sit amet, consectetur adipiscing elit')
          page.add_commit_message(commit_message)
          page.commit_changes
        end
      end

    end
  end
end
