module QA
  module Page
    module File
      class Created < Page::Base
        view 'app/views/projects/commits/_commit.html.haml' do
          element :commit_sha
        end

        def commit_sha
          find_element(:commit_sha).text
        end
      end
    end
  end
end
