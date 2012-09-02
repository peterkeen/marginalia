require 'redcarpet'
require 'openssl'

class Note < ActiveRecord::Base
  acts_as_taggable
  has_paper_trail

  belongs_to :user

  before_save :extract_tags
  before_create :populate_unique

  def extract_tags
    newtags = Set.new
    body.scan(/\s#([a-zA-Z]\w+)/) do |t|
      newtags << t
    end
    self.tag_list = newtags.sort.join(', ')
  end

  def rendered_body
    markdown = Redcarpet::Markdown.new(
      RenderWithTags.new(
        :safe_links_only => true,
        :no_styles => true,
        :timezone => self.user.time_zone
      ),
      :strikethrough => true,
      :space_after_headers => true,
      :autolink => true,
      :tables => true,
      :fenced_code_blocks => true
    )
    markdown.render(body)
  end

  def populate_unique
    self.unique_id = SecureRandom.hex(20)
  end

  def append_to_body(text)
    date = Time.now().utc.strftime('@%Y-%m-%dT%H:%M:%S')
    self.body += "\n\n#{date}\n\n#{text}"
    self.save
  end

  def share(email)
    if self.share_id == nil
      self.share_id = SecureRandom.hex(20)
      self.save
    end
    NoteMailer.delay.share(self.id, email)
  end

  def unshare
    self.share_id = nil
    self.save
  end

  def version_id
    live? ? versions.last.id : version.id
  end

end
