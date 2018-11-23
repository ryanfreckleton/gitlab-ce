# frozen_string_literal: true

module Suggestions
  class CreateService
    def initialize(diff_note)
      @diff_note = diff_note
    end

    def execute
      suggestions = Banzai::SuggestionsParser.parse(@diff_note.note)

      suggestions.each do |suggestion|
        @diff_note.suggestions.create(changing: @diff_note.diff_line.text,
                           suggestion: suggestion)
      end
    end
  end
end
