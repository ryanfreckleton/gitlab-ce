require "spec_helper"

describe Files::UpdateService do
  subject { described_class.new(project, user, commit_params) }

  let(:project) { create(:project, :repository) }
  let(:user) { create(:user, :commit_email) }
  let(:file_path) { 'files/ruby/popen.rb' }
  let(:new_contents) { 'New Content' }
  let(:branch_name) { project.default_branch }
  let(:last_commit_sha) { nil }
  let(:commit) { project.repository.commit }
  let(:from_line) { nil }
  let(:to_line) { nil }

  let(:commit_params) do
    {
      file_path: file_path,
      commit_message: "Update File",
      file_content: new_contents,
      file_content_encoding: "text",
      last_commit_sha: last_commit_sha,
      start_project: project,
      start_branch: project.default_branch,
      branch_name: branch_name,
      from_line: from_line,
      to_line: to_line
    }
  end

  before do
    project.add_maintainer(user)
  end

  describe "#execute" do
    context "when the file's last commit sha does not match the supplied last_commit_sha" do
      let(:last_commit_sha) { "foo" }

      it "returns a hash with the correct error message and a :error status " do
        expect { subject.execute }
          .to raise_error(Files::UpdateService::FileChangedError,
                         "You are attempting to update a file that has changed since you started editing it.")
      end
    end

    context "when the file's last commit sha does match the supplied last_commit_sha" do
      let(:last_commit_sha) { Gitlab::Git::Commit.last_for_path(project.repository, project.default_branch, file_path).sha }

      it "returns a hash with the :success status " do
        results = subject.execute

        expect(results[:status]).to match(:success)
      end

      it "updates the file with the new contents" do
        subject.execute

        results = project.repository.blob_at_branch(project.default_branch, file_path)

        expect(results.data).to eq(new_contents)
      end

      it 'uses the commit email' do
        subject.execute

        expect(user.commit_email).not_to eq(user.email)
        expect(commit.author_email).to eq(user.commit_email)
        expect(commit.committer_email).to eq(user.commit_email)
      end

      context 'when should apply content as patch' do
        context 'valid range' do
          let(:from_line) { 8 }
          let(:to_line) { 10 }

          let(:new_contents) do
            <<-CONTENT
    if !cmd.is_a?(Array)
      raise RuntimeError,
        "System commands must be given as an array of strings"
    end
            CONTENT
          end

          let(:expected_content) do
            <<-CONTENT.strip_heredoc
            require 'fileutils'
            require 'open3'

            module Popen
              extend self

              def popen(cmd, path=nil)
                if !cmd.is_a?(Array)
                  raise RuntimeError,
                    "System commands must be given as an array of strings"
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
            subject.execute

            result = project.repository.blob_at_branch(project.default_branch, file_path)

            expect(result.data).to eq(expected_content)
          end
        end

        context 'invalid range' do
          context 'when range surpasses file lines size' do
            let(:from_line) { 8 }
            let(:to_line) { 999 }

            it 'raises PatchUpdateError' do
              expect { subject.execute }
                .to raise_error(described_class::PatchUpdateError, 'Given line surpasses the scope of the file.')
            end
          end

          context 'when lines does not have positive value' do
            let(:from_line) { -1 }
            let(:to_line) { 20 }

            it 'raises PatchUpdateError' do
              expect { subject.execute }
                .to raise_error(described_class::PatchUpdateError, 'Invalid range.')
            end
          end

          context 'when from_line value is higher than to_line' do
            let(:from_line) { 20 }
            let(:to_line) { 10 }

            it 'raises PatchUpdateError' do
              expect { subject.execute }
                .to raise_error(described_class::PatchUpdateError, 'Invalid range.')
            end
          end

          context 'when blob is not found' do
            before do
              expect_next_instance_of(Repository) do |repo|
                allow(repo).to receive(:blob_at_branch) { nil }
              end
            end

            let(:from_line) { 3 }
            let(:to_line) { 3 }

            it 'raises PatchUpdateError' do
              expect { subject.execute }
                .to raise_error(described_class::PatchUpdateError, 'Blob not found.')
            end
          end
        end
      end
    end

    context "when the last_commit_sha is not supplied" do
      it "returns a hash with the :success status " do
        results = subject.execute

        expect(results[:status]).to match(:success)
      end

      it "updates the file with the new contents" do
        subject.execute

        results = project.repository.blob_at_branch(project.default_branch, file_path)

        expect(results.data).to eq(new_contents)
      end
    end
  end
end
