# frozen_string_literal: true

module Gitlab
  module Ci
    module Pipeline
      module Chain
        module Validate
          class Config < Chain::Base
            include Chain::Helpers

            MERGE_REQUEST_KEYWORDS = %w(merge_request merge_requests).freeze

            def perform!
              unless @pipeline.config_processor
                unless @pipeline.ci_yaml_file
                  return error("Missing #{@pipeline.ci_yaml_file_path} file")
                end

                if @command.save_incompleted && @pipeline.has_yaml_errors?
                  @pipeline.drop!(:config_error)
                end

                error(@pipeline.yaml_errors)
              end

              ##
              # At the moment, we don't create merge request pipelines unless
              # users specify "only/except: merge_requests" in .gitlab-ci.yml.
              #
              # This is for avoiding confusion that, after they upgraded GitLab
              # version to 11.6, two type of pipelines (One is push sourced pipeline,
              # another one is merge request sourced pipeline) are created when
              # user does `git push` to a merge request.
              #
              # This logic is a subject to change. Once we decided to make merge
              # request pipelines as the default pipeline for merge requests,
              # instead of branch pipelines, we can remove the following logic.
              #
              # See more https://gitlab.com/gitlab-org/gitlab-ce/issues/15310#note_111177091
              if @pipeline.config_processor && @pipeline.merge_request?
                unless has_jobs_with_merge_request_condition?
                  error('Merge request pipelines cannot be created ' \
                        'unless .gitlab-ci.yml contains "only/except: merge_requests"')
                end
              end
            end

            def break?
              @pipeline.errors.any? || @pipeline.persisted?
            end

            private

            def has_jobs_with_merge_request_condition?
              @pipeline.config_processor.jobs.any? do |_, v|
                only_refs = v.dig(:only, :refs) || []
                except_refs = v.dig(:except, :refs) || []

                MERGE_REQUEST_KEYWORDS.any? do |word|
                  only_refs.include?(word) || except_refs.include?(word)
                end
              end
            end
          end
        end
      end
    end
  end
end
