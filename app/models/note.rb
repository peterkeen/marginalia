require 'redcarpet'
require 'openssl'

class Note < ActiveRecord::Base
  acts_as_taggable
  has_paper_trail

  before_save :extract_tags
  before_create :populate_unique

  def extract_tags
    newtags = Set.new
    body.scan(/[^\w#]#(\w+)\b/) do |t|
      newtags << t
    end
    self.tag_list = newtags.sort.join(', ')
  end

  def rendered_body
    markdown = Redcarpet::Markdown.new(
      RenderWithTags, 
      :strikethrough => true,
      :space_after_headers => true,
      :autolink => true,
      :fenced_code_blocks => true
    )
    markdown.render(body)
  end

  def populate_unique
    self.unique_id = SecureRandom.hex(20)
  end

end
