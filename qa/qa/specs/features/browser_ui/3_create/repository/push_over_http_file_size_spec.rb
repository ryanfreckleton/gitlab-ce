# frozen_string_literal: true

module QA
  context 'Create'  do
    describe 'push after setting the file size limit via admin/application_settings' do
      before(:all) do
        @project = Resource::Repository::ProjectPush.fabricate! do |p|
          p.file_name = 'README.md'
          p.file_content = '# This is a test project'
          p.commit_message = 'Add README.md'
        end
      end

      before do
        Runtime::Browser.visit(:gitlab, Page::Main::Login)
        Page::Main::Login.act { sign_in_using_credentials }

        # this creates a 15mb file which is approximately  2mb when compressed
        # need to create a new content otherwise it doesn't give error for the exactly same content files
        content = SecureRandom.hex(1000000)
        @file_content = content.unpack("B*")
      end

      after do
        # need to set the default value after test
        # default value for file size limit is empty
        set_file_size_limit('')
      end

      it 'developers push successfully when the file size is under the limit' do
        set_file_size_limit 5
        expect(get_file_size_limit).to eql('5')

        @project.project.visit!

        push = push_new_file('oversize_file_1.bin')
        expect(push.output).not_to have_content 'remote: fatal: pack exceeds maximum allowed size'
      end

      it 'developers get error when the file is is above the limit ' do
        set_file_size_limit 1
        expect(get_file_size_limit).to eql('1')

        @project.project.visit!

        push = push_new_file('oversize_file_2.bin')
        expect(push.output).to have_content 'remote: fatal: pack exceeds maximum allowed size'
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

      def get_file_size_limit
        Page::Main::Menu.perform(&:go_to_admin_area)
        Page::Admin::Menu.perform(&:go_to_general_settings)

        Page::Admin::Settings::General.perform do |setting|
          setting.expand_account_and_limit do |page|
            page.get_max_file_size
          end
        end
      end

      def push_new_file(file_name)
        Resource::Repository::ProjectPush.fabricate! do |p|
          p.project = @project
          p.file_name = file_name
          p.file_content = @file_content
          p.commit_message = 'Adding a new file'
        end
      end
    end
  end
end
