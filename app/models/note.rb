require 'redcarpet'
require 'openssl'

class Note < ActiveRecord::Base

  MAX_GUEST_NOTES_COUNT = 4
  
  acts_as_taggable
  has_paper_trail

  belongs_to :user
  belongs_to :project
  acts_as_list :scope => :project

  before_save :extract_tags
  before_save :update_word_count
  before_create :populate_unique

  validates_presence_of :body
  validates_presence_of :title

  validate :guests_can_only_make_a_few_notes

  attr_accessor :new_email_address, :new_password, :limit_reached, :newsletter_subscribe

  has_many :shares, :dependent => :destroy

  def guests_can_only_make_a_few_notes
    if user.is_guest && user.notes.count >= MAX_GUEST_NOTES_COUNT
      self.limit_reached = true
      errors[:base] << "You've created as many notes as your trial allows"
    end
  end

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
    new_share = Share.create(:note => self, :email => email, :unique_id => SecureRandom.hex(20))
    NoteMailer.delay.share(new_share.id)
  end

  def unshare
    self.share_id = nil
    self.save
  end

  def version_id
    (live? && !versions.empty?) ? versions.last.id : version.nil? ? 0 : version.id
  end

  def update_word_count
    self.word_count = (self.body || "").scan(/\w+/).length
  end

end
