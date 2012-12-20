require 'date'

class RenderWithTags < Redcarpet::Render::HTML

  def initialize(*args)
    super(*args)
    options = args.pop

    @no_sanitize = options[:no_sanitize]
    @timezone = options[:timezone] || 'Pacific Time (US & Canada)'
    @page_data = []
  end

  def preprocess(full_document)
    full_document.gsub!(/(\s)#([a-zA-Z]\w+)/) do |match|
      "#{$1}[##{$2}](/tags/#{$2})"
    end

    full_document.gsub!(/(\s)#(\d+)/) do |match|
      "#{$1}[##{$2}](/notes/#{$2})"
    end


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

  def block_code(code, language)
    output =  "<pre><code>#{code}</code></pre>"
    if language == "data"
      data = JSON.load(code) rescue nil
      if data
        data['date'] = @current_date
        @page_data << data
        output = '<div class="datablock"></div>'
      end
    elsif language == "javascript:embed"
      output = <<HERE
<script type="text/javascript">
#{code}
</script>
HERE
    elsif language == "javascript:require"
      requires = code.split("\n").map(&:strip)
      output = requires.map { |r| "<script type=\"text/javascript\" src=\"#{r}\"></script>" }.join("\n")
    end
    output
  end

  def normal_text(text)
    text = text.gsub(/{{(\w+)\((.*)\)}}/) do |match|
      func = Sanitize.clean($1)
      args = Sanitize.clean($2).split(/,/)

      if !('A'..'Z').include?(func[0])
        match[0]
      else
        self.send(func.to_sym, *args)
      end
    end
  end

  def paragraph(text)
    if text.match(/^@(\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d)$/)
      date = DateTime.parse($1).to_time.in_time_zone(@timezone)
      @current_date = date
      return "<div class=\"date\"><hr><b>#{date.strftime('%Y %b %d %l:%M %P')}</b></div>"
    end
    "<p>#{text}</p>"
  end

  def postprocess(full_document)
    if @page_data.length > 0
      <<HERE
<script type="text/javascript">
  window.pageData = #{@page_data.to_json};
  $(function() {
    $('div.datablock').prev('div.date').hide();
  });
</script>
#{full_document}
HERE
    else
      full_document
    end
  end
  
  def Label(label, level="default")
    label_class = level == "default" ? '' : " label-#{level}"
    "<span class='label#{label_class}'>#{label}</span>"
  end

end
