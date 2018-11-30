# frozen_string_literal: true

module Gitlab
  class WikiFileFinder < FileFinder
    private

    def search_filenames(query, except)
      safe_query = Regexp.escape(query.tr(' ', '-'))
      safe_query = Regexp.new(safe_query, Regexp::IGNORECASE)
      filenames = project.wiki.repository.ls_files(ref)

      filenames.delete_if { |filename| except.include?(filename) } unless except.empty?

      filenames.grep(safe_query).first(BATCH_SIZE)
    end
  end
end
