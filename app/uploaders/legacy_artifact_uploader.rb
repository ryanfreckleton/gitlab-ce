# frozen_string_literal: true

##
# TODO: Remove this uploader when we remove :ci_enable_legacy_artifacts feature flag
class LegacyArtifactUploader < GitlabUploader
  extend Workhorse::UploadPath
  include ObjectStorage::Concern

  ObjectNotReadyError = Class.new(StandardError)

  storage_options Gitlab.config.artifacts

  alias_method :upload, :model

  def store_dir
    dynamic_segment
  end

  private

  def dynamic_segment
    raise ObjectNotReadyError, 'Build is not ready' unless model.id

    File.join(model.created_at.utc.strftime('%Y_%m'), model.project_id.to_s, model.id.to_s)
  end
end
