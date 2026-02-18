module ActiveStorageTestHelpers
  def create_file_blob(filename: 'sample.jpg', content_type: 'image/jpeg', metadata: nil)
    ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join('spec/support/files', filename)),
      filename: filename,
      content_type: content_type,
      metadata: metadata
    )
  end
end
