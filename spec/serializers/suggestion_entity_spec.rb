# frozen_string_literal: true

require 'spec_helper'

describe SuggestionEntity do
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
                                        position: position)
  end

  let!(:suggestion) do
    create(:suggestion, diff_note: diff_note,
                        changing: '    vars = {',
                        suggestion: 'bar',
                        relative_order: 0)
  end

  let(:entity) do
    described_class.new(suggestion)
  end

  context 'as json' do
    subject { entity.as_json }

    it 'exposes attributes' do
      expect(subject).to include(:id, :from_line, :to_line,
                                 :appliable, :applied, :changing,
                                 :suggestion)
    end
  end
end
