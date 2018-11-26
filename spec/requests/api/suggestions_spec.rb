# frozen_string_literal: true

require 'spec_helper'

describe API::Suggestions do
  let(:project) { create(:project, :repository) }
  let(:user) { create(:user) }

  let(:merge_request) do
    create(:merge_request, source_project: project,
                           target_project: project)
  end

  let(:position) do
    Gitlab::Diff::Position.new(old_path: "files/ruby/popen.rb",
                               new_path: "files/ruby/popen.rb",
                               old_line: nil,
                               new_line: 9,
                               diff_refs: merge_request.diff_refs)
  end

  let!(:diff_note) do
    create(:diff_note_on_merge_request, noteable: merge_request,
                                        position: position,
                                        project: project)
  end

  let!(:suggestion) do
    create(:suggestion, note: diff_note,
                        changing: "      raise RuntimeError, \"System commands must be given as an array of strings\"\n",
                        suggestion: "      raise RuntimeError, 'Explosion'\n      # explosion?\n",
                        relative_order: 0)
  end

  # TODO: Add more tests
  describe "PUT /suggestions/:id/apply" do
    before do
      project.add_maintainer(user)
    end

    let(:url) { "/suggestions/#{suggestion.id}/apply" }

    it 'applies suggestion patch' do
      put api(url, user), id: suggestion.id

      expect(response).to have_gitlab_http_status(200)
    end
  end
end
