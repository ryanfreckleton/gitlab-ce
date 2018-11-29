module QA
  context 'Manage' do
    let(:issue_title) {'issue for to close'}

    describe 'e' do


      def push_file(issue_id)
        Resource::Repository::ProjectPush.fabricate! do |push|
          push.file_name = 'README.md'
          push.file_content = '# This is a test project'
          push.commit_message = "Closes ##{issue_id}"
        end
      end

      def create_issue
        Runtime::Browser.visit(:gitlab, Page::Main::Login)
        Page::Main::Login.act {sign_in_using_credentials}

        Resource::Issue.fabricate! do |issue|
          issue.title = issue_title
        end
      end

      def issue_id
        Page::Project::Issue::Show.act {
          issue_id
        }
      end

      it 'does something' do
        create_issue

        puts issue_id
      end


    end
  end
end
