module UploadsHelper
  def fixture_base64_file_upload(path)
    "data:image/jpeg;base64,#{Base64.encode64(fixture_file_upload(path).read)}"
  end
end
