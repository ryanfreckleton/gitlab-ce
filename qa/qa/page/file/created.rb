module QA
  module Page
    module File
      class Created < Page::Base
        def commit_sha
          page.within('div.commit-sha-group') do
            find('div.label').text
          end
        end
      end
    end
  end
end
