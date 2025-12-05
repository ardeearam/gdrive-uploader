require "google/apis/drive_v3"
require "googleauth"
require "googleauth/stores/file_token_store"
require "fileutils"

DRIVE = Google::Apis::DriveV3
SCOPE = ["https://www.googleapis.com/auth/drive"]
OOB_URI = "urn:ietf:wg:oauth:2.0:oob"

CLIENT_SECRETS_PATH = "client_secrets.json"
CREDENTIALS_PATH = File.join(Dir.home, ".credentials", "drive-ruby-quickstart.yaml")
FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

def authorize
  client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
  user_id = "default"
  credentials = authorizer.get_credentials(user_id)
  
  if credentials.nil?
    url = authorizer.get_authorization_url(base_url: OOB_URI)
    puts "Open the following URL in your browser and enter the resulting code:"
    puts url
    print "Enter the code: "
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI
    )
  end
  credentials
end

def build_service
  service = DRIVE::DriveService.new
  service.client_options.application_name = "Drive Uploader"
  service.authorization = authorize
  service
end

def move_single_file_into_gdrive(local_path, new_name: nil, folder_id: nil)
  service = build_service

  filename = new_name || File.basename(local_path)


  file_metadata = DRIVE::File.new(name: filename)
  file_metadata.parents = [folder_id] if folder_id

  # Upload
  uploaded = service.create_file(
    file_metadata,
    upload_source: local_path,
    content_type: "application/octet-stream",
    fields: "id"
  )

  file_id = uploaded.id

  # Verify the upload
  begin
    service.get_file(file_id, fields: "id")
    # If we get here, file exists → delete local
    File.delete(local_path)
    puts "✨ Moved to Google Drive: #{filename} (id=#{file_id})"
  rescue Google::Apis::ClientError
    puts "⚠️ Upload failed — local file NOT deleted."
  end

  file_id
end

def create_folder(folder_name, parent_folder_id: nil)
  service = build_service

  file_metadata = DRIVE::File.new(
    name: folder_name,
    mime_type: "application/vnd.google-apps.folder"
  )
  file_metadata.parents = [parent_folder_id] if parent_folder_id

  folder = service.create_file(
    file_metadata,
    fields: "id, name, mimeType"
  )

  puts "✓ Created folder: #{folder.name} (id: #{folder.id})"
  folder.id
end

def move_directory_files_into_gdrive(directory_path,  folder_id: nil)
  service = build_service
  
  # Verify folder access
  if folder_id
    begin
      folder = service.get_file(folder_id, fields: "id, name, mimeType")
      puts "✓ Folder accessible: #{folder.name}"
      puts "  MIME type: #{folder.mime_type}"
      puts "  Folder ID: #{folder.id}"
    rescue Google::Apis::ClientError => e
      puts "✗ Cannot access folder: #{e.message}"
      raise
    end
  end

  Dir.glob(File.join(File.expand_path(directory_path), '*')).each do |file_path|
    next unless File.file?(file_path)
    move_single_file_into_gdrive(file_path, folder_id: folder_id)
  end
end

windows_bir_ardee_relly_root_folder_id = "15LbzXJEtttMOhdAOT9A_HSaw4L1g45nr"
test_folder_id = "1XHuQUSBLiy8kM1L3vIeREQW4n9FhKwo2"
move_directory_files_into_gdrive(ARGV[0], folder_id: ARGV[1])
