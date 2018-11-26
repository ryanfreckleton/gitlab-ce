# frozen_string_literal: true

module QA
  module Resource
    class IssueBoard < Base
      attr_writer :issues_count

      attribute :project do
        Project.fabricate! do |resource|
          resource.name = 'project-for-issue-boards'
          resource.description = 'project for adding issue boards'
        end
      end

      def fabricate!
        for i in 1..@issues_count
          project.visit!

          Page::Project::Show.perform(&:go_to_new_issue)

          Page::Project::Issue::New.perform do |page|
            page.add_title("issue title #{i}")
            page.add_description("My awesome issue #{i}")
            page.create_new_issue
          end
        end
      end
    end
  end
end
