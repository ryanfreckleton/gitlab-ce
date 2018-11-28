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

  let(:diff_note) do
    create(:diff_note_on_merge_request, noteable: merge_request,
                                        position: position,
                                        project: project)
  end

  describe "PUT /suggestions/:id/apply" do
    let(:url) { "/suggestions/#{suggestion.id}/apply" }

    context 'when successfully applies patch' do
      let(:suggestion) do
        create(:suggestion, diff_note: diff_note,
                            changing: "      raise RuntimeError, \"System commands must be given as an array of strings\"\n",
                            suggestion: "      raise RuntimeError, 'Explosion'\n      # explosion?\n")
      end

      before do
        project.add_maintainer(user)
      end

      it 'returns 200 with json content' do
        put api(url, user), id: suggestion.id

        expect(response).to have_gitlab_http_status(200)
        expect(json_response)
          .to include('id', 'from_line', 'to_line', 'appliable', 'applied', 'changing', 'suggestion')
      end
    end

    context 'when unauthorized' do
      let(:suggestion) do
        create(:suggestion, diff_note: diff_note,
                            changing: "      raise RuntimeError, \"System commands must be given as an array of strings\"\n",
                            suggestion: "      raise RuntimeError, 'Explosion'\n      # explosion?\n")
      end

      before do
        project.add_reporter(user)
      end

      it 'returns 403 with json content' do
        put api(url, user), id: suggestion.id

        expect(response).to have_gitlab_http_status(403)
        expect(json_response).to eq({ 'message' => '403 Forbidden' })
      end
    end

    context 'when not able to apply patch' do
      let(:suggestion) do
        create(:suggestion, :unappliable, diff_note: diff_note)
      end

      before do
        project.add_maintainer(user)
      end

      it 'returns 400 with json content' do
        put api(url, user), id: suggestion.id

        expect(response).to have_gitlab_http_status(400)
        expect(json_response).to eq({ 'message' => 'Suggestion is not appliable' })
      end
    end
  end
end
