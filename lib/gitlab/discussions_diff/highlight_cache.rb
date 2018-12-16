# frozen_string_literal: true
#
module Gitlab
  module DiscussionsDiff
    class HighlightCache
      class << self
        # Sets multiple keys to a given value.
        #
        # mapping - A Hash mapping the cache keys to their values.
        # Values are normally expected to be arrays of Hashes,
        # therefore, Marshal is used.
        def write_multiple(mapping)
          Redis::Cache.with do |redis|
            redis.multi do |multi|
              mapping.each do |raw_key, value|
                key = cache_key_for(raw_key)

                multi.set(key, value, ex: 1.week)
              end
            end
          end
        end

        # Reads multiple cache keys at once.
        #
        # raw_keys - An array of unique cache keys.
        # Cache namespaces are not included.
        def read_multiple(raw_keys)
          return [] if raw_keys.empty?

          keys = raw_keys.map { |id| cache_key_for(id) }

          Redis::Cache.with do |redis|
            redis.mget(keys)
          end
        end

        def cache_key_for(raw_key)
          "#{cache_key_prefix}:#{raw_key}"
        end

        private

        def cache_key_prefix
          "#{Redis::Cache::CACHE_NAMESPACE}:#{Diff::Line::SERIALIZE_KEYS}:discussion-highlight"
        end
      end
    end
  end
end
