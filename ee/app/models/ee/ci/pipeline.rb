module EE
  module Ci
    module Pipeline
      extend ActiveSupport::Concern

      EE_FAILURE_REASONS = {
        activity_limit_exceeded: 20,
        size_limit_exceeded: 21
      }.freeze

      prepended do
        has_one :chat_data, class_name: 'Ci::PipelineChatData'

        has_many :job_artifacts, through: :builds

        scope :with_security_reports, -> {
          joins(:artifacts).where(ci_builds: { name: %w[sast dependency_scanning sast:container container_scanning dast] })
        }

        # Deprecated, to be removed in 12.0
        # A hash of Ci::JobArtifact file_types
        # With mapping to the legacy job names,
        # that has to contain given files
        LEGACY_REPORT_FORMATS = {
          codequality: {
            names: %w(codeclimate codequality code_quality),
            files: %w(codeclimate.json gl-code-quality-report.json)
          }
        }.freeze
      end

      def artifact_for_file_type(file_type)
        job_artifacts.where(file_type: ::Ci::JobArtifact.file_types[file_type]).last
      end

      def legacy_report_artifact_for_file_type(file_type)
        legacy_names = LEGACY_REPORT_FORMATS[file_type]
        return unless legacy_names

        builds.success.latest.where(name: legacy_names[:names]).each do |build|
          legacy_names[:files].each do |file_name|
            next unless build.has_artifact?(file_name)

            return OpenStruct.new(build: build, path: file_name)
          end
        end

        # In case there is no artifact return nil
        nil
      end

      def performance_artifact
        @performance_artifact ||= artifacts_with_files.find(&:has_performance_json?)
      end

      def sast_artifact
        @sast_artifact ||= artifacts_with_files.find(&:has_sast_json?)
      end

      def dependency_scanning_artifact
        @dependency_scanning_artifact ||= artifacts_with_files.find(&:has_dependency_scanning_json?)
      end

      def license_management_artifact
        @license_management_artifact ||= artifacts_with_files.find(&:has_license_management_json?)
      end

      # sast_container_artifact is deprecated and replaced with container_scanning_artifact (#5778)
      def sast_container_artifact
        @sast_container_artifact ||= artifacts_with_files.find(&:has_sast_container_json?)
      end

      def container_scanning_artifact
        @container_scanning_artifact ||= artifacts_with_files.find(&:has_container_scanning_json?)
      end

      def dast_artifact
        @dast_artifact ||= artifacts_with_files.find(&:has_dast_json?)
      end

      def has_sast_data?
        sast_artifact&.success?
      end

      def has_dependency_scanning_data?
        dependency_scanning_artifact&.success?
      end

      def has_license_management_data?
        license_management_artifact&.success?
      end

      # has_sast_container_data? is deprecated and replaced with has_container_scanning_data? (#5778)
      def has_sast_container_data?
        sast_container_artifact&.success?
      end

      def has_container_scanning_data?
        container_scanning_artifact&.success?
      end

      def has_dast_data?
        dast_artifact&.success?
      end

      def has_performance_data?
        performance_artifact&.success?
      end

      def expose_sast_data?
        project.feature_available?(:sast) &&
          has_sast_data?
      end

      def expose_dependency_scanning_data?
        project.feature_available?(:dependency_scanning) &&
          has_dependency_scanning_data?
      end

      def expose_license_management_data?
        project.feature_available?(:license_management) &&
          has_license_management_data?
      end

      # expose_sast_container_data? is deprecated and replaced with expose_container_scanning_data? (#5778)
      def expose_sast_container_data?
        project.feature_available?(:sast_container) &&
          has_sast_container_data?
      end

      def expose_container_scanning_data?
        project.feature_available?(:sast_container) &&
          has_container_scanning_data?
      end

      def expose_dast_data?
        project.feature_available?(:dast) &&
          has_dast_data?
      end

      def expose_performance_data?
        project.feature_available?(:merge_request_performance_metrics) &&
          has_performance_data?
      end

      def expose_security_dashboard?
        expose_sast_data? ||
          expose_dependency_scanning_data? ||
          expose_dast_data? ||
          expose_sast_container_data? ||
          expose_container_scanning_data?
      end

      private

      def artifacts_with_files
        @artifacts_with_files ||= artifacts.includes(:job_artifacts_metadata, :job_artifacts_archive).to_a
      end
    end
  end
end