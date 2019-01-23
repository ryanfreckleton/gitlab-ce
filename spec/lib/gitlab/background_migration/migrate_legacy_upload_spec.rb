require 'spec_helper'

describe Gitlab::BackgroundMigration::MigrateLegacyUploads, :migration, schema: 20190103140724 do
  let(:test_dir) { FileUploader.options['storage_path'] }

  let!(:namespace) { create(:namespace) }
  let!(:project) { create(:project, :legacy_storage, namespace: namespace) }
  let!(:issue) { create(:issue, project: project) }

  let!(:note1) { create(:note, note: 'some note text awesome', project: project, attachment: 'image.png', noteable: issue) }
  let!(:note2) { create(:note, note: 'some note', project: project, attachment: 'text.pdf', noteable: issue) }
  let!(:note3) { create(:note, note: 'some note', project: project, attachment: 'text.pdf', noteable: issue) }

  let!(:hashed_project) { create(:project, namespace: namespace) }
  let!(:issue_hashed_project) { create(:issue, project: hashed_project) }
  let!(:note_hashed_project) { create(:note, note: 'some note', project: hashed_project, attachment: 'text.pdf', noteable: issue_hashed_project) }

  let(:legacy_upload1) do
    create(:upload,
      path: "uploads/-/system/note/attachment/#{note1.id}/image.png", mount_point: 'attachment',
      model_id: note1.id, model_type: 'Note', uploader: 'AttachmentUploader', secret: nil)
  end
  let(:legacy_upload2) do
    create(:upload,
      path: "uploads/-/system/note/attachment/#{note2.id}/non-existing.pdf", mount_point: 'attachment',
      model_id: note2.id, model_type: 'Note', uploader: 'AttachmentUploader', secret: nil)
  end
  let(:legacy_upload_hashed) do
    create(:upload,
      path: "uploads/-/system/note/attachment/#{note_hashed_project.id}/text.pdf", mount_point: 'attachment',
      model_id: note_hashed_project.id, model_type: 'Note', uploader: 'AttachmentUploader', secret: nil)
  end
  let!(:standard_upload) do
    create(:upload,
      path: "secretabcde/image.png",
      model_id: create(:project).id, model_type: 'Project', uploader: 'FileUploader')
  end
  let!(:legacy_uploads) { [ legacy_upload1, legacy_upload2, legacy_upload_hashed] }

  def new_upload_legacy
    Upload.find_by(model_id: project.id, model_type: 'Project')
  end

  def new_upload_hashed
    Upload.find_by(model_id: hashed_project.id, model_type: 'Project')
  end

  before do
    absolute_path = File.join(test_dir, legacy_upload1.path)
    FileUtils.mkdir_p(File.dirname(absolute_path))
    FileUtils.touch(absolute_path)

    absolute_path = File.join(test_dir, legacy_upload_hashed.path)
    FileUtils.mkdir_p(File.dirname(absolute_path))
    FileUtils.touch(absolute_path)
  end

  shared_examples 'migrates files correctly' do
    before do
      described_class.new.perform
    end

    it 'removes all the legacy upload records' do
      expect { legacy_upload1.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { legacy_upload2.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { legacy_upload_hashed.reload }.to raise_error(ActiveRecord::RecordNotFound)

      expect(standard_upload.reload).to eq(standard_upload)
    end

    it 'creates new upload records correctly' do
      expect(new_upload_legacy.secret).not_to be_nil
      expect(new_upload_legacy.path).to end_with("#{new_upload_legacy.secret}/image.png")
      expect(new_upload_legacy.model_id).to eq(project.id)
      expect(new_upload_legacy.model_type).to eq('Project')
      expect(new_upload_legacy.uploader).to eq('FileUploader')

      expect(new_upload_hashed.secret).not_to be_nil
      expect(new_upload_hashed.path).to end_with("#{new_upload_hashed.secret}/text.pdf")
      expect(new_upload_hashed.model_id).to eq(hashed_project.id)
      expect(new_upload_hashed.model_type).to eq('Project')
      expect(new_upload_hashed.uploader).to eq('FileUploader')
    end

    it 'updates the legacy upload notes so that they include the file references in the mardown' do
      expected_path = File.join('/uploads', new_upload_legacy.secret, 'image.png')
      expected_markdown = "some note text awesome \n ![image](#{expected_path})"
      expect(note1.reload.note).to eq(expected_markdown)

      expected_path = File.join('/uploads', new_upload_hashed.secret, 'text.pdf')
      expected_markdown = "some note \n [text.pdf](#{expected_path})"
      expect(note_hashed_project.reload.note).to eq(expected_markdown)
    end
  end

  context 'when object storage is disabled' do
    it_behaves_like 'migrates files correctly'

    it 'moves legacy uploads to the correct location' do
      described_class.new.perform

      expected_path1 = File.join(test_dir, 'uploads', namespace.path, project.path, new_upload_legacy.secret, 'image.png')
      expected_path2 = File.join(test_dir, 'uploads', hashed_project.disk_path, new_upload_hashed.secret, 'text.pdf')

      expect(File.exist?(expected_path1)).to be_truthy
      expect(File.exist?(expected_path2)).to be_truthy
    end
  end

  context 'when object storage is enabled for FileUploader' do
    context 'when direct_upload is enabled' do
      before do
        stub_uploads_object_storage(FileUploader, direct_upload: true)
      end

      it_behaves_like 'migrates files correctly'

      it 'moves legacy uploads to the correct remote location' do
        described_class.new.perform

        connection = ::Fog::Storage.new(FileUploader.object_store_credentials)
        expect(connection.get_object('uploads', new_upload_legacy.path)[:status]).to eq(200)
        expect(connection.get_object('uploads', new_upload_hashed.path)[:status]).to eq(200)
      end
    end

    context 'when direct_upload is disabled' do
      before do
        stub_uploads_object_storage(FileUploader, direct_upload: false)
      end

      it_behaves_like 'migrates files correctly'

      it 'moves legacy uploads to the correct local location' do
        described_class.new.perform

        expected_path1 = File.join(test_dir, 'uploads', namespace.path, project.path, new_upload_legacy.secret, 'image.png')
        expected_path2 = File.join(test_dir, 'uploads', hashed_project.disk_path, new_upload_hashed.secret, 'text.pdf')

        expect(File.exist?(expected_path1)).to be_truthy
        expect(File.exist?(expected_path2)).to be_truthy
      end
    end
  end

  context 'when the upload move fails' do
    it 'does not return old uploads' do
      upload_service = double(execute: nil)
      expect(UploadService).to receive(:new).twice.and_return(upload_service)

      described_class.new.perform

      expect(legacy_upload1.reload).to eq(legacy_upload1)
      expect(legacy_upload_hashed.reload).to eq(legacy_upload_hashed)
      expect(standard_upload.reload).to eq(standard_upload)
    end
  end
end
