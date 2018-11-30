# frozen_string_literal: true

module Gitlab
  class ProjectSearchResults < SearchResults
    attr_reader :project, :repository_ref

    def initialize(current_user, project, query, repository_ref = nil, per_page: 20)
      @current_user = current_user
      @project = project
      @repository_ref = repository_ref.presence
      @query = query
      @per_page = per_page
    end

    def objects(scope, page = nil)
      case scope
      when 'notes'
        notes.page(page).per(per_page)
      when 'blobs'
        blobs(page: page)
      when 'wiki_blobs'
        wiki_blobs(page: page)
      when 'commits'
        Kaminari.paginate_array(commits).page(page).per(per_page)
      else
        super(scope, page, false)
      end
    end

    def blobs_count
      @blobs_count ||= blobs.total_count
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def limited_notes_count
      return @limited_notes_count if defined?(@limited_notes_count)

      types = %w(issue merge_request commit snippet)
      @limited_notes_count = 0

      types.each do |type|
        @limited_notes_count += notes_finder(type).limit(count_limit).count
        break if @limited_notes_count >= count_limit
      end

      @limited_notes_count
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def wiki_blobs_count
      @wiki_blobs_count ||= wiki_blobs.total_count
    end

    def commits_count
      @commits_count ||= commits.count
    end

    def self.parse_search_result(result, project = nil)
      ref = nil
      filename = nil
      basename = nil

      data = []
      startline = 0

      result.each_line.each_with_index do |line, index|
        prefix ||= line.match(/^(?<ref>[^:]*):(?<filename>[^\x00]*)\x00(?<startline>\d+)\x00/)&.tap do |matches|
          ref = matches[:ref]
          filename = matches[:filename]
          startline = matches[:startline]
          startline = startline.to_i - index
          extname = Regexp.escape(File.extname(filename))
          basename = filename.sub(/#{extname}$/, '')
        end

        data << line.sub(prefix.to_s, '')
      end

      FoundBlob.new(
        filename: filename,
        basename: basename,
        ref: ref,
        startline: startline,
        data: data.join,
        project: project
      )
    end

    def single_commit_result?
      return false if commits_count != 1

      counts = %i(limited_milestones_count limited_notes_count
                  limited_merge_requests_count limited_issues_count
                  blobs_count wiki_blobs_count)
      counts.all? { |count_method| public_send(count_method).zero? } # rubocop:disable GitlabSecurity/PublicSend
    end

    private

    def blobs(page: nil)
      return Kaminari.paginate_array([]) unless Ability.allowed?(@current_user, :download_code, @project)

      @blobs ||= Gitlab::FileFinder.new(project, repository_project_ref, page: page, per_page: per_page).find(query)
    end

    def wiki_blobs(page: nil)
      unless Ability.allowed?(@current_user, :read_wiki, @project)
        return Kaminari.paginate_array([])
      end

      @wiki_blobs ||= begin
        if project.wiki_enabled? && query.present? && !project.wiki.empty?
          Gitlab::WikiFileFinder.new(project, repository_wiki_ref, page: page, per_page: per_page, limit: count_limit).find(query)
        else
          Kaminari.paginate_array([])
        end
      end
    end

    def notes
      @notes ||= notes_finder(nil)
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def notes_finder(type)
      NotesFinder.new(project, @current_user, search: query, target_type: type).execute.user.order('updated_at DESC')
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def commits
      @commits ||= find_commits(query)
    end

    def find_commits(query)
      return [] unless Ability.allowed?(@current_user, :download_code, @project)

      commits = find_commits_by_message(query)
      commit_by_sha = find_commit_by_sha(query)
      commits |= [commit_by_sha] if commit_by_sha
      commits
    end

    def find_commits_by_message(query)
      project.repository.find_commits_by_message(query)
    end

    def find_commit_by_sha(query)
      key = query.strip
      project.repository.commit(key) if Commit.valid_hash?(key)
    end

    def project_ids_relation
      project
    end

    def repository_project_ref
      @repository_project_ref ||= repository_ref || project.default_branch
    end

    def repository_wiki_ref
      @repository_wiki_ref ||= repository_ref || project.wiki.default_branch
    end
  end
end
