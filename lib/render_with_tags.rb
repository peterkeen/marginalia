require 'date'

class RenderWithTags < Redcarpet::Render::HTML
  def preprocess(full_document)
    full_document.gsub!(/\s#([a-zA-Z]\w+)/) do |match|
      "[##{$1}](/tags/#{$1})"
    end

    full_document.gsub!(/\s#(\d+)/) do |match|
      "[##{$1}](/notes/#{$1})"
    end

    current_date = nil
    full_document.gsub!(/@(\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d)/) do |match|
      date = DateTime.parse($1).to_time.in_time_zone('Pacific Time (US & Canada)')
      "* * *\n**#{date.strftime('%Y %b %d %l:%M %P')}**\n\n" 
    end

    full_document
  end
end
