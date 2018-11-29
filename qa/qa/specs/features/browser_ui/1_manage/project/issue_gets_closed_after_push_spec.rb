module QA
  context 'Manage' do
    let(:issue_title) {'issue for to close'}

    describe 'e' do


      def push_file(issue_id)
        Page::Project::Menu.act {click_project}
        Page::Project::Show.act { create_new_file! }
        Page::File::Form.perform do |page|
          page.add_name('dummy')
          page.add_content('Enable the Web IDE')
          page.add_commit_message("Closes ##{issue_id}")
          page.commit_changes
        end
      end

      def deactivate_auto_devops
        Page::Project::Menu.act do
          click_ci_cd_settings
        end
        Page::Project::Settings::CICD.act do
          disable_auto_devops
        end
      end

      def create_issue
        Runtime::Browser.visit(:gitlab, Page::Main::Login)
        Page::Main::Login.act {sign_in_using_credentials}

        Resource::Issue.fabricate! do |issue|
          issue.title = issue_title
        end
        Page::Project::Issue::Show.act {issue_id}
      end

      it 'does something' do

        issue_id = create_issue
        deactivate_auto_devops
        push_file(issue_id)

        Page::Project::Menu.act {click_issues}

        Page::Project::Issue::Index.act {
          click_on_closed
          go_to_issue(issue_title)
        }

      end


    end
  end
end
