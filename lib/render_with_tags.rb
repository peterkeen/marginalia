class RenderWithTags < Redcarpet::Render::HTML
  def preprocess(full_document)
    full_document.gsub(/[^\w#]#(\w+)\b/) do |match|
      " [##{$1}](/tags/#{$1}) "
    end
  end
end
