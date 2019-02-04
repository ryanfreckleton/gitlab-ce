# frozen_string_literal: true

module Gitlab
  module Ci
    module Parsers
      ParserNotFoundError = Class.new(ParserError)

      def self.parsers
        {
          junit: ::Gitlab::Ci::Parsers::Test::Junit,
          build_annotation: ::Gitlab::Ci::Parsers::BuildAnnotation
        }
      end

      def self.fabricate!(file_type)
        parsers.fetch(file_type.to_sym).new
      rescue KeyError
        raise ParserNotFoundError, "Cannot find any parser matching file type '#{file_type}'"
      end
    end
  end
end
