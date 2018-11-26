require 'spec_helper'

describe Suggestions::ApplyService do
  let(:project) { create(:project, :repository) }
  let(:user) { create(:user, :commit_email) }

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

  subject { described_class.new(user) }

  context 'patch is appliable' do
    before do
      project.add_maintainer(user)
    end

    let(:expected_content) do
      <<-CONTENT.strip_heredoc
          require 'fileutils'
          require 'open3'

          module Popen
            extend self

            def popen(cmd, path=nil)
              unless cmd.is_a?(Array)
                raise RuntimeError, 'Explosion'
                # explosion?
              end

              path ||= Dir.pwd

              vars = {
                "PWD" => path
              }

              options = {
                chdir: path
              }

              unless File.directory?(path)
                FileUtils.mkdir_p(path)
              end

              @cmd_output = ""
              @cmd_status = 0

              Open3.popen3(vars, *cmd, options) do |stdin, stdout, stderr, wait_thr|
                @cmd_output << stdout.read
                @cmd_output << stderr.read
                @cmd_status = wait_thr.value.exitstatus
              end

              return @cmd_output, @cmd_status
            end
          end
      CONTENT
    end

    it 'updates the file with the new contents' do
      subject.execute(suggestion)

      blob = project.repository.blob_at_branch(merge_request.source_branch,
                                               position.new_path)

      expect(blob.data).to eq(expected_content)
    end

    it 'returns success status' do
      result = subject.execute(suggestion)

      expect(result[:status]).to eq(:success)
    end

    it 'updates suggestion applied column' do
      expect { subject.execute(suggestion) }
        .to change(suggestion, :applied)
        .from(false).to(true)
    end
  end

  context 'no permission' do
    context 'user cannot write in project repo' do
      before do
        project.add_reporter(user)
      end

      it 'returns error' do
        result = subject.execute(suggestion)

        expect(result).to eq(message: "You are not allowed to push into this branch",
                             status: :error)
      end
    end
  end

  context 'patch is not appliable' do
    before do
      project.add_maintainer(user)
    end

    context 'suggestion was already applied' do
      it 'returns success status' do
        result = subject.execute(suggestion)

        expect(result[:status]).to eq(:success)
      end
    end

    context 'note is outdated' do
      before do
        allow(diff_note).to receive(:active?) { false }
      end

      it 'returns error message' do
        result = subject.execute(suggestion)

        expect(result).to eq(message: 'Suggestion is not appliable',
                             status: :error)
      end
    end

    context 'suggestion was already applied' do
      before do
        suggestion.update!(applied: true)
      end

      it 'returns error message' do
        result = subject.execute(suggestion)

        expect(result).to eq(message: 'Suggestion is not appliable',
                             status: :error)
      end
    end
  end
end
