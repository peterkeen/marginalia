require 'zip/zip'
require 'tempfile'
require 'json'
require 'aws/s3'

class ExportJob < Struct.new(:user_id, :project_id)

  def user_time(time)
    time.in_time_zone(@user.time_zone).strftime("%Y %b %d %l:%M %P")
  end

  def perform
    @file = Tempfile.new(["export_#{user_id}_", '.zip'])
    path = @file.path
    @file.close(true)
    @file.unlink
    @user = User.find(user_id) or return
    @export = Export.create(:user_id => user_id)

    Zip::ZipFile.open(path, Zip::ZipFile::CREATE) do |zipfile|
      if project_id
        @notes = @user.notes.where(:project_id => project_id)
      else
        @notes = @user.notes
      end
      @notes.each do |note|
        add_note(zipfile, note)
      end
      zipfile.get_output_stream("README.txt") do |f|
        f.write <<HERE
Marginalia Export
-----------------

Created for #{@user.name} <#{@user.email}> at #{user_time(Time.now)}.

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

    unless @user.has_guest_email?
      ExportMailer.export_done(user_id, @export.id).deliver
    end

    puts "http://#{ENV['AWS_EXPORT_BUCKET']}.s3.amazonaws.com/#{@export.filename}"

    return @export
  end

  def add_note(zipfile, note)
    dir = "#{note.title} - #{note.id.to_s}"
    zipfile.mkdir(dir)

    note.versions.each do |version|
      v = version.reify
      next unless v
      write_version(zipfile, note.id, v, dir)
    end

    write_version(zipfile, note.id, note, dir, "current")

    zipfile.commit()
  end

  def write_version(zipfile, id, version, dir, filename=nil)
    filename ||= version.updated_at.in_time_zone(@user.time_zone).strftime("%Y%m%d-%H%M%S")
    zipfile.get_output_stream("#{dir}/#{filename}.md") do |f|
      f.puts "Title: #{version.title}"
      f.puts "Date: #{user_time(version.updated_at)}"
      f.puts "From: #{version.from_address}"
      f.puts ""
      f.write version.body
    end
  end
end
