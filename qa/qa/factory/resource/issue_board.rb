module QA
  module Factory
    module Resource
      class IssueBoard< Factory::Base
        attr_accessor :title, :description, :project

        dependency Factory::Resource::Issue, as: :project do |project|
          project.name = 'project-for-issueboards'
          project.description = 'project for testing issue boards'
        end

        product :project
        product :title

        def fabricate!
          project.visit!

          Page::Project::Show.act do
            go_to_new_issue
          end

          Page::Project::IssueBoard::New.perform do |page|
            page.add_title(@title)
            page.add_description(@description)
            page.create_new_issue
          end
        end
      end
    end
  end
end
