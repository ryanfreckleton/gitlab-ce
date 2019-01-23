# frozen_string_literal: true

# This migration takes all legacy uploads (that were uploaded using AttachmentUploader)
# and migrate them to the new (FileUploader) location (=under projects).
#
# We have dependencies (uploaders) in this migration because extracting code would add a lot of complexity
# and possible errors could appear as the logic in the uploaders is not trivial.
#
# This migration will be removed in 12.0 in order to get rid of a migration that depends on
# the application code.
module Gitlab
  module BackgroundMigration
    class MigrateLegacyUploads
      include Database::MigrationHelpers

      class Upload < ActiveRecord::Base
        include EachBatch
      end

      class UploadMover
        include Gitlab::Utils::StrongMemoize

        attr_reader :upload, :project, :note

        def initialize(upload)
          @upload = upload
          @note = Note.find_by(id: upload.model_id)
          @project = note&.project
        end

        def execute
          return unless upload

          if !project
            # if we don't have models associated with the upload we can not move it
            say "MigrateLegacyUploads: Model for #{upload.inspect} not found. Deleting."
            destroy_upload = true
          elsif !legacy_file_uploader.exists?
            # if we can not find the file we just remove the upload record
            say "MigrateLegacyUploads: Upload #{upload.inspect} file not found. Deleting."
            destroy_upload = true
          elsif create_project_upload
            update_note
            destroy_upload = true
          end

          destroy_legacy_upload if destroy_upload
        end

        private

        def create_project_upload
          @uploader = UploadService.new(project, legacy_file).execute

          if @uploader
            say "MigrateLegacyUploads: Moved file #{legacy_file_uploader.file.path} -> #{@uploader.file.path}"
            true
          else
            say "MigrateLegacyUploads: File #{legacy_file_uploader.file.path} hasn't been moved"
            false
          end
        end

        def destroy_legacy_upload
          upload.destroy
          say "MigrateLegacyUploads: Upload #{upload.inspect} was destroyed."
        end

        def update_note
          new_text = "#{note.note} \n #{@uploader.markdown_link}"
          note.update!(
            note: new_text
          )
        end

        def legacy_file_uploader
          strong_memoize(:legacy_file_uploader) do
            file_name = File.basename(upload.path)
            uploader = AttachmentUploader.new(note, upload.mount_point, secret: upload.secret)
            uploader.retrieve_from_store!(file_name)

            uploader
          end
        end

        def legacy_file
          legacy_file_uploader.file
        end

        def say(message)
          Rails.logger.info(message)
        end
      end

      def perform
        Upload.where(uploader: 'AttachmentUploader').each_batch do |batch|
          batch.each { |upload| UploadMover.new(upload).execute }
        end
      end
    end
  end
end
