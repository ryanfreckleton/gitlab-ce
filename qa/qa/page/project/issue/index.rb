module QA
  module Page
    module Project
      module Issue
        class Index < Page::Base
          view 'app/views/projects/issues/_issue.html.haml' do
            element :issue_link, 'link_to issue.title' # rubocop:disable QA/ElementWithPattern
          end

          view 'app/views/shared/issuable/_nav.html.haml' do
            element :closed_elements_link
          end

          def click_on_closed
            click_element :closed_elements_link
          end

          def go_to_issue(title)
            click_link(title)
          end
        end
      end
    end
  end
end
