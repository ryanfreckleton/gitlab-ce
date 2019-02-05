# frozen_string_literal: true

require 'net/http'
require 'yaml'

class Teammate
  attr_reader :name, :projects, :gitlab

  def initialize(options = {})
    @name = options['name']
    @projects = options['projects']
    @gitlab = options['gitlab']
  end

  def in_project?(name)
    projects&.has_key?(name)
  end

  # Traintainers also count as reviewers
  def reviewer?(project, category)
    capabilities(project) == "reviewer #{category}" || traintainer?(project, category)
  end

  def traintainer?(project, category)
    capabilities(project) == "trainee_maintainer #{category}"
  end

  def maintainer?(project, category)
    capabilities(project) == "maintainer #{category}"
  end

  private

  def capabilities(project)
    projects.fetch(project, '')
  end
end

module Danger
  # Common helper functions for our danger scripts
  # If we find ourselves repeating code in our danger files, we might as well put them in here.
  class Helper < Plugin
    TEAM_DATA_URL = URI.parse('https://gitlab.com/gitlab-com/www-gitlab-com/raw/master/data/team.yml').freeze

    # Returns a list of all files that have been added, modified or renamed.
    # `git.modified_files` might contain paths that already have been renamed,
    # so we need to remove them from the list.
    #
    # Considering these changes:
    #
    # - A new_file.rb
    # - D deleted_file.rb
    # - M modified_file.rb
    # - R renamed_file_before.rb -> renamed_file_after.rb
    #
    # it will return
    # ```
    # [ 'new_file.rb', 'modified_file.rb', 'renamed_file_after.rb' ]
    # ```
    #
    # @return [Array<String>]
    def all_changed_files
      Set.new
        .merge(git.added_files.to_a)
        .merge(git.modified_files.to_a)
        .merge(git.renamed_files.map { |x| x[:after] })
        .subtract(git.renamed_files.map { |x| x[:before] })
        .to_a
        .sort
    end

    # @return [Boolean]
    def ee?
      ENV['CI_PROJECT_NAME'] == 'gitlab-ee' || File.exist?('../../CHANGELOG-EE.md')
    end

    def project_name
      ee? ? 'gitlab-ee' : 'gitlab-ce'
    end

    def team
      Psych.safe_load(Net::HTTP.get(TEAM_DATA_URL), [Date]).map { |hash| Teammate.new(hash) }
    end

    def project_team
      team.select { |member| member.in_project?(project_name) }
    end

    # @return [Hash<String,Array<String>>]
    def changes_by_category
      all_changed_files.inject(Hash.new { |h, k| h[k] = [] }) do |hash, file|
        hash[category_for_file(file)] << file
        hash
      end
    end

    def category_for_file(file)
      _, category = CATEGORIES.find { |regexp, _| regexp.match?(file) }

      category || :unknown
    end

    CATEGORIES = {
      %r{\Adoc/} => :documentation,
      %r{\A(CONTRIBUTING|LICENSE|MAINTENANCE|PHILOSOPHY|PROCESS|README)(\.md)?\z/} => :documentation,

      %r{\A(ee/)?app/(assets|views)/} => :frontend,
      %r{\A(ee/)?public/} => :frontend,
      %r{\A(ee/)?vendor/assets/} => :frontend,
      %r{\A(jest\.config\.js|package\.json|yarn\.lock)\z} => :frontend,

      %r{\A(ee/)?app/(controllers|finders|graphql|helpers|mailers|models|policies|presenters|serializers|services|uploaders|validators|workers)/} => :backend,
      %r{\A(ee/)?(bin|config|danger|generator_templates|lib|rubocop|scripts|spec)/} => :backend,
      %r{\A(ee/)?vendor/(cert_manager|Dockerfile|gitignore|ingress|jupyter|project_templates|prometheus|runner)/} => :backend,
      %r{\A(ee/)?vendor/(languages\.yml|licenses\.csv)\z/} => :backend,
      %r{\A(Gemfile|Gemfile.lock)\z} => :backend,
      %r{\A(GITALY_SERVER_VERSION|GITLAB_PAGES_VERSION|GITLAB_SHELL_VERSION|GITLAB_WORKHORSE_VERSION|Rakefile)\z} => :backend,

      %r{\A(ee/)?db/} => :database,
      %r{\A(ee/)?qa/} => :qa
    }.freeze
  end
end
