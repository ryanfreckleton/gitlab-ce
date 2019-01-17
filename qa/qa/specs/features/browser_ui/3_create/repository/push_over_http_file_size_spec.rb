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

      before(:all) do
        # this creates a 8mb file which is 1.1mb when compressed
        content = (0...1000000).map { ('a'..'z').to_a[rand(26)] }.join
        @file_content = content.unpack("B*")
      end

      context 'when developers push files less size then the limit' do
        it 'they successfully push' do
          set_file_size_limit 2

          push = Resource::Repository::ProjectPush.fabricate! do |p|
            p.project = project
            p.file_name = 'oversize_file_1.bin'
            p.file_content = @file_content
            p.commit_message = 'file size is less than the limit'
          end

          expect(push.output).not_to have_content 'remote: fatal: pack exceeds maximum allowed size'
        end
      end

      context 'when developers push oversize files' do
        it 'they get an error' do
          set_file_size_limit 1

          push = Resource::Repository::ProjectPush.fabricate! do |p|
            p.project = project
            p.file_name = 'oversize_file_2.bin'
            p.file_content = @file_content
            p.commit_message = 'Adding a oversize file'
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
