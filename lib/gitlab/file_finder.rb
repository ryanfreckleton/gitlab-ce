# frozen_string_literal: true

# This class finds files in a repository by name and content
# the result is joined and sorted by file name
module Gitlab
  class FileFinder
    class BaseMatch
      attr_reader :match

      def initialize(match)
        @match = match
      end
    end

    class ContentMatch < BaseMatch
      FILENAME_REGEXP = /\A(?<ref>[^:]*):(?<filename>[^\x00]*)\x00/.freeze

      def filename
        # FIXME - use const, match may not be found
        # FIXME - check if utf8 is needed
        @filename ||= match.match(FILENAME_REGEXP)[:filename]
      end

      def found_blob(project, ref)
        Gitlab::ProjectSearchResults.parse_search_result(match, project)
      end
    end

    class FilenameMatch < BaseMatch
      attr_accessor :blob, :ref

      def filename
        match
      end

      def found_blob(project, ref)
        Gitlab::SearchResults::FoundBlob.new(
          id: blob.id,
          filename: blob.path,
          basename: File.basename(blob.path, File.extname(blob.path)),
          ref: ref,
          startline: 1,
          data: blob.data,
          project: project
        )
      end
    end

    attr_reader :project, :ref, :page, :per_page, :query

    delegate :repository, to: :project

    def initialize(project, ref, page: 1, per_page: 20)
      @project = project
      @ref = ref
      @page = page
      @per_page = [per_page.to_i, 100].min
    end

    def find(query)
      @query = Gitlab::Search::Query.new(query) do
        filter :filename, matcher: ->(filter, blob) { blob.filename =~ /#{filter[:regex_value]}$/i }
        filter :path, matcher: ->(filter, blob) { blob.filename =~ /#{filter[:regex_value]}/i }
        filter :extension, matcher: ->(filter, blob) { blob.filename =~ /\.#{filter[:regex_value]}$/i }
      end

      results = Kaminari.paginate_array(find_by_filename + find_by_content).page(page).per(per_page)

      # convert to blob only items on the selected page of array
      replace_filename_blobs!(results)
      replace_content_blobs!(results)

      results.each_with_index { |blob, idx| results[idx] = [blob.filename, blob] }

      results
    end

    private

    def replace_content_blobs!(array)
      array.each_with_index do |item, idx|
        next unless item.is_a?(ContentMatch)
        array[idx] = item.found_blob(project, ref)
      end
    end

    def replace_filename_blobs!(array)
      filenames = array.select { |a| a.is_a?(FilenameMatch) }.map(&:match)
      blobs = blobs(filenames)

      array.each_with_index do |item, idx|
        next unless item.is_a?(FilenameMatch)
        item.blob = blobs.find { |b| b.path == item.match }
        array[idx] = item.found_blob(project, ref)
      end
    end

    def find_by_content
      files = repository.search_files_by_content(query.term, ref)

      filter_matches(ContentMatch, files)
    end

    def find_by_filename
      filenames = repository.search_files_by_name(query.term, ref)

      filter_matches(FilenameMatch, filenames)
    end

    def filter_matches(match_class, matches)
      matches = matches.map { |match| match_class.new(match) }

      matches = query.filter_results(matches) if query.filters.any?

      matches
    end

    def blob_refs(filenames)
      filenames.map { |filename| [ref, filename] }
    end

    def blobs(filenames)
      Gitlab::Git::Blob.batch(repository, blob_refs(filenames), blob_size_limit: 1024)
    end
  end
end
