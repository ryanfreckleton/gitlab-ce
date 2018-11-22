# frozen_string_literal: true

module Banzai
  module Filter
    class SuggestionFilter < HTML::Pipeline::Filter
      # Class used for tagging elements that should be rendered
      TAG_CLASS = 'js-render-suggestion'.freeze

      # Why's of fetching diff-notes here:
      # 1. We need to provide highlighted content for both
      #    changing and suggested lines. Though FE is able to fetch
      #    the highlighted data for the former, it would need to change
      #    the data for the suggested line in order to highlight.
      # 2. Backend should be able to say the diff is outdated,
      #    therefore FE shouldn't be able to allow applying patches.
      # 3. For non-outdated diff notes with suggestions in
      #    `Discussion` tab, FE has little context of the current version
      #    diff.
      # TODO:
      # - Add .js-blob-code-addition
      # - Add .js-blob-code-deletion
      # - Add a data-outdated-comment
      #
      def call
        # Temporary:
        diff_note = DiffNote.last
        blob_lines = diff_note.diff_file.new_blob.lines
        changed_lines = Array.wrap(blob_lines[diff_note.diff_line.new_pos - 1])
        #

        suggestion_nodes = doc.search('pre.suggestion')
        suggestion_nodes.wrap(wrapper)

        suggestion_nodes.search('> code').each do |node|
          additions = doc.document.create_element(
            'div',
            class: 'js-blob-code-addition'
          )
          deletions = doc.document.create_element(
            'div',
            class: 'js-blob-code-deletion'
          )

          additions.content = changed_lines.join("\n")
          deletions.content = node.text

          node.parent.parent.add_child(additions)
          node.parent.parent.add_child(deletions)

          node.add_class(TAG_CLASS)
        end

        doc
      end

      def wrapper(outdated: false)
        %(<div class='suggestion-wrapper'
               data-suggestion> </div>)
      end
    end
  end
end
