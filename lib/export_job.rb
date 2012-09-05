require 'zip/zip'
require 'tempfile'
require 'json'

class ExportJob < Struct.new(:user_id)
  def perform
    @file = Tempfile.new(["export_#{user_id}_", '.zip'])
    path = @file.path
    @file.close(true)
    @file.unlink
    @user = User.find(user_id) or return
    @export = Export.create(:user_id => user_id)

    Zip::ZipFile.open(path, Zip::ZipFile::CREATE) do |zipfile|
      @user.notes.each do |note|
        add_note(zipfile, note)
      end
      zipfile.get_output_stream("README.txt") do |f|
        f.write <<HERE
Marginalia Export
-----------------

Created for #{@user.name} <#{@user.email}> at #{Time.now.rfc822}.

This is an export from Marginalia. Each directory is a note, and each file within
the directory is the version of that note created at the timestamp in the filename.

Each version file contains a header with the title, date, and from address of the note,
a single blank line, and then the body of the note.
HERE
      end
    end

    @export.filename = File.basename(path)

    AWS::S3::Base.establish_connection!(
      :access_key_id     => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
    )

    AWS::S3::S3Object.store(
      @export.filename,
      File.open(path),
      ENV['AWS_EXPORT_BUCKET'],
      :content_type => 'application/zip',
      :access => :public_read
    )

    @export.save!

    ExportMailer.export_done(user_id, @export.id).deliver

    puts "http://#{ENV['AWS_EXPORT_BUCKET']}.s3.amazonaws.com/#{@export.filename}"

  end

  def add_note(zipfile, note)
    zipfile.mkdir(note.id.to_s)

    note.versions.each do |version|
      v = version.reify
      next unless v
      created_at = v.created_at.strftime("%Y-%m-%d_%H%M%S")
      zipfile.get_output_stream("#{note.id.to_s}/#{created_at}.md") do |f|
        f.puts "Title: #{v.title}"
        f.puts "Date: #{v.created_at.rfc822}"
        f.puts "From: #{v.from_address}"
        f.puts ""
        f.write v.body
      end
    end

    zipfile.commit()
  end
end
