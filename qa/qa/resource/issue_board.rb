# frozen_string_literal: true

module QA
  module Resource
    class IssueBoard < Base
      attr_writer :issues

      attribute :project do
        Project.fabricate! do |resource|
          resource.name = 'project-for-issue-boards'
          resource.description = 'project for adding issue boards'
        end
      end

      def fabricate!
        @issues.each do |issue|
          project.visit!

          Page::Project::Show.perform(&:go_to_new_issue)

          Page::Project::Issue::New.perform do |page|
            page.add_title(issue[:title])
            page.add_description(issue[:description])
            page.create_new_issue
          end
        end
      end
    end
  end
end
