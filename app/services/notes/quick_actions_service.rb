# frozen_string_literal: true

module Notes
  class QuickActionsService < BaseService
    extend Gitlab::Utils::StrongMemoize

    def self.update_services
      strong_memoize(:update_services) do
        {
          'Issue' => Issues::UpdateService,
          'MergeRequest' => MergeRequests::UpdateService,
          'Commit' => Commits::TagService
        }
      end
    end

    def self.noteable_update_service(note)
      update_services[note.noteable_type]
    end

    def self.supported?(note)
      !!noteable_update_service(note)
    end

    def supported?(note)
      self.class.supported?(note)
    end

    def extract_commands(note, options = {})
      return [note.note, {}] unless supported?(note)

      QuickActions::InterpretService.new(project, current_user, options)
        .execute(note.note, note.noteable)
    end

    def execute(command_params, note)
      return if command_params.empty?
      return unless supported?(note)

      self.class.noteable_update_service(note).new(note.parent, current_user, command_params).execute(note.noteable)
    end
  end
end
