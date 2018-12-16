# frozen_string_literal: true

module Gitlab
  module DiscussionsDiff
    class FileCollection
      include Gitlab::Utils::StrongMemoize

      def initialize(collection)
        @collection = collection
      end

      def find_by_id(id)
        diff_files_indexed_by_id[id]
      end

      def preload_all
        write_empty_cache_keys
        preload_highlighted_lines
      end

      private

      def preload_highlighted_lines
        cached_content = read_cache

        diffs.zip(cached_content).each do |diff, content|
          next unless content

          # The data structure being loaded here is in control
          # of the system and cannot be sploited by
          # user data.
          content = Marshal.load(content) # rubocop:disable Security/MarshalLoad

          highlighted_diff_lines = content.map do |line|
            Gitlab::Diff::Line.init_from_hash(line)
          end

          diff.highlighted_diff_lines = highlighted_diff_lines
        end
      end

      def read_cache
        strong_memoize(:read_all) do
          HighlightCache.read_multiple(ids)
        end
      end

      def write_empty_cache_keys
        cached_content = read_cache

        uncached_ids = ids.select.each_with_index { |_, i| cached_content[i].nil? }
        mapping = highlighted_lines_by_id(uncached_ids)

        HighlightCache.write_multiple(mapping)
      end

      def ids
        @collection.map(&:id)
      end

      def diff_files_indexed_by_id
        strong_memoize(:diff_files_indexed_by_id) do
          diffs.index_by { |diff| diff.unique_identifier }
        end
      end

      def diffs
        strong_memoize(:diffs) do
          @collection.map { |diff| decorate_diff(diff) }
        end
      end

      def highlighted_lines_by_id(ids)
        diff_files_indexed_by_id.select { |id, _| ids.include?(id) }.map do |id, file|
          raw_content = file.highlighted_diff_lines.map(&:to_hash)

          [id, Marshal.dump(raw_content)]
        end
      end

      def decorate_diff(diff)
        raw_diff = Gitlab::Git::Diff.new(diff.to_hash)

        Gitlab::Diff::File.new(raw_diff,
                               repository: diff.project.repository,
                               diff_refs: diff.original_position.diff_refs,
                               unique_identifier: diff.id)
      end
    end
  end
end
