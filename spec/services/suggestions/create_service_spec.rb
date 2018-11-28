# frozen_string_literal: true

require 'spec_helper'

describe Suggestions::CreateService do
  let(:project_with_repo) { create(:project, :repository) }
  let(:merge_request) do
    create(:merge_request, source_project: project_with_repo,
                           target_project: project_with_repo)
  end

  let(:position) do
    Gitlab::Diff::Position.new(old_path: "files/ruby/popen.rb",
                               new_path: "files/ruby/popen.rb",
                               old_line: nil,
                               new_line: 14,
                               diff_refs: merge_request.diff_refs)
  end

  let(:diff_note) do
    create(:diff_note_on_merge_request, project: project_with_repo,
                                        noteable: merge_request,
                                        position: position,
                                        note: markdown)
  end

  let(:markdown) do
    <<-MARKDOWN.strip_heredoc
        ```suggestion
          foo
          bar
        ```

        ```
          nothing
        ```

        ```suggestion
          xpto
          baz
        ```

        ```thing
          this is not a suggestion, it's a thing
        ```
    MARKDOWN
  end

  subject { described_class.new(diff_note) }

  describe '#execute' do
    context 'should not try to parse suggestions' do
      context 'when diff note is not for text' do
        it 'does not try to parse suggestions' do
          allow(diff_note).to receive(:on_text?) { false }

          expect(Banzai::SuggestionsParser).not_to receive(:parse)

          subject.execute
        end
      end

      context 'when diff file new blob does not exists' do
        it 'does not try to parse suggestions' do
          allow(diff_note).to receive_message_chain(:diff_file, :new_blob) { nil }

          expect(Banzai::SuggestionsParser).not_to receive(:parse)

          subject.execute
        end
      end
    end

    context 'should create suggestions' do
      context 'single line suggestions' do
        it 'persists suggestion records' do
          expect { subject.execute }
            .to change { diff_note.suggestions.count }
            .from(0)
            .to(2)
        end

        it 'persists original changing lines and suggested lines' do
          subject.execute

          suggestions = diff_note.suggestions.order(:relative_order)

          suggestion_1 = suggestions.first
          suggestion_2 = suggestions.last

          expect(suggestion_1).to have_attributes(changing: "    vars = {\n",
                                                  suggestion: "  foo\n  bar\n")

          expect(suggestion_2).to have_attributes(changing: "    vars = {\n",
                                                  suggestion: "  xpto\n  baz\n")
        end
      end
    end
  end
end
