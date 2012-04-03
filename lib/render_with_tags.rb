require 'date'

class RenderWithTags < Redcarpet::Render::HTML

  def initialize
    super

    @burndown = Burndown.new
  end

  def preprocess(full_document)
    full_document.gsub!(/(\s)#([a-zA-Z]\w+)/) do |match|
      "#{$1}[##{$2}](/tags/#{$2})"
    end

    full_document.gsub!(/(\s)#(\d+)/) do |match|
      "#{$1}[##{$2}](/notes/#{$2})"
    end

    current_date = nil
    full_document.gsub!(/@(\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d)/) do |match|
      date = DateTime.parse($1).to_time.in_time_zone('Pacific Time (US & Canada)')
      "* * *\n**#{date.strftime('%Y %b %d %l:%M %P')}**\n\n" 
    end

    @burndown.preprocess(full_document)

    full_document
  end

  def paragraph(text)
    @burndown.paragraph(text)
    "<p>#{text}</p>"
  end

  def header(text, header_level)
    @burndown.header(text)
    "<h#{header_level}>#{text}</h#{header_level}>"
  end

  def postprocess(full_document)
    return @burndown.postprocess(full_document)
  end

end
