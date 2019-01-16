module QA
  context 'Create', :ldap_no_tls do
    describe 'push over HTTP' do
      let(:project) do
        Resource::Repository::ProjectPush.fabricate! do |p|
          p.file_name = 'README.md'
          p.file_content = '# This is a test project'
          p.commit_message = 'Add README.md'
        end
      end

      before do
        Runtime::Browser.visit(:gitlab, Page::Main::Login)
        Page::Main::Login.act { sign_in_using_credentials }
      end

      context 'when developers push files less size then the limit' do
        it 'they successfully push' do
          set_file_size_limit 2

          push = Resource::Repository::ProjectPush.fabricate! do |p|
            p.project = project
            p.file_name = 'oversize_file_1.txt'
            # this creates a 553mb file which is 1.7mb when compressed
            p.file_content = "Creating a oversize file for testing the limit for push,\n" * 10000000
            p.commit_message = 'Adding oversize file'
          end

          expect(push.output).not_to have_content 'remote: fatal: pack exceeds maximum allowed size'
        end
      end

      context 'when developers push oversize files' do
        it 'they get an error' do
          set_file_size_limit 1

          push = Resource::Repository::ProjectPush.fabricate! do |p|
            p.project = project
            p.file_name = 'oversize_file_2.txt'
            p.file_content = "Creating a oversize file for testing the limit for push.\n" * 10000000
            p.commit_message = 'Adding oversize file'
          end

          expect(push.output).to have_content 'remote: fatal: pack exceeds maximum allowed size'
        end
      end

      def set_file_size_limit(limit)
        Page::Main::Menu.perform(&:go_to_admin_area)
        Page::Admin::Menu.perform(&:go_to_general_settings)

        Page::Admin::Settings::General.perform do |setting|
          setting.expand_account_and_limit do |page|
            page.set_max_file_size(limit)
            page.save_settings
          end
        end
      end
    end
  end
end
