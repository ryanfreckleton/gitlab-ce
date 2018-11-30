module QA
  module Page
    module File
      class Created < Page::Base
        view 'app/views/projects/commits/_commit.html.haml' do
          element :commit_sha_group
        end

        def commit_sha
          within_element(:commit_sha_group) do
            find('div.label').text
          end
        end
      end
    end
  end
end
