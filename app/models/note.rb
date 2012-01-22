require 'redcarpet'
require 'openssl'

class Note < ActiveRecord::Base
  acts_as_taggable
  has_paper_trail

  before_save :extract_tags

  def extract_tags
    tags = Set.new
    body.scan(/[^\w#]#(\w+)\b/) do |tag|
      tags << tag
    end
    self.tag_list = tags.sort.join(', ')
  end

  def rendered_body
    markdown = Redcarpet::Markdown.new(RenderWithTags)
    markdown.render(body)
  end

  def self.new_from_mailgun_post(params)
    obj = self.new
    if validate_mailgun_signature(params)
      obj.title = params['subject']
      obj.body = params['stripped-text']
      obj.from_address = params['from']
    else
      obj.errors << 'Invalid Signature'
    end
  end

  def self.validate_mailgun_signature(params)
    signature = params['signature']
    return false if signature.nil?

    test_signature = OpenSSL::HMAC.hexdigest(
      OpenSSL::Digest::Digest.new('sha256'),
      ENV['MAILGUN_API_KEY'],
      '%s%s' % [params['timestamp'], params['token']
    )

    return signature == test_signature
  end
end
