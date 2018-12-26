# frozen_string_literal: true

# Gitaly note: JV: does not need to be migrated, works without a repo.

module Gitlab
  module GitRefValidator
    extend self
    DISALLOWED_PREFIXES = %w(refs/heads/ refs/remotes/ -).freeze

    # Validates a given name against the git reference specification
    #
    # Returns true for a valid reference name, false otherwise
    def validate(ref_name, not_allowed_prefixes = DISALLOWED_PREFIXES)
      return false if ref_name.start_with?(*not_allowed_prefixes)
      return false if ref_name == 'HEAD'

      begin
        Rugged::Reference.valid_name?("refs/heads/#{ref_name}")
      rescue ArgumentError
        return false
      end
    end
  end
end
