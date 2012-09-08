require 'date'

class RenderWithTags < Redcarpet::Render::HTML

  def initialize(*args)
    super(*args)
    options = args.pop

    @no_sanitize = options[:no_sanitize]
    @timezone = options[:timezone] || 'Pacific Time (US & Canada)'
    
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
      date = DateTime.parse($1).to_time.in_time_zone(@timezone)
      "* * *\n**#{date.strftime('%Y %b %d %l:%M %P')}**\n\n" 
    end

    @burndown.preprocess(full_document)

    full_document
  end

  def raw_html(html)
    return html if @no_sanitize
    Sanitize.clean(html, Sanitize::Config::RELAXED)
  end

  def block_html(html)
    return html if @no_sanitize
    Sanitize.clean(html, Sanitize::Config::RELAXED)
  end

  def paragraph(text)
    @burndown.paragraph(text)
    "<p>#{text}</p>"
  end

  def header(text, header_level)
    @burndown.header(text)
    "<h#{header_level}>#{text}</h#{header_level}>"
  end

  def normal_text(text)
    text.gsub!(/{{(\w+)\((.*)\)}}/) do |match|
      func = Sanitize.clean($1)
      args = Sanitize.clean($2).split(/,/)

      if !('A'..'Z').include?(func[0])
        ""
      else
        self.send(func.to_sym, *args)
      end
    end
  end


  def postprocess(full_document)

    
    return @burndown.postprocess(full_document)
  end

  def Label(label, level="default")
    label_class = level == "default" ? '' : " label-#{level}"
    "<span class='label#{label_class}'>#{label}</span>"
  end

end
