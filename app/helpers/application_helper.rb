module ApplicationHelper
  def is_guest?
    ! session[:guest_user_id].nil?
  end

  def is_admin?
    current_or_guest_user.is_admin
  end

  def markdown
    text = capture do
      yield
    end
    renderer = Redcarpet::Markdown.new(
      RenderWithTags,
      :strikethrough => true,
      :space_after_headers => true,
      :autolink => true,
      :fenced_code_blocks => true
    )
    renderer.render(text).html_safe
  end

  def current_or_guest_user
    if current_user
      if session[:guest_user_id]
        logging_in
        guest_user.destroy
        session[:guest_user_id] = nil
      end
      current_user
    else
      guest_user
    end
  end


end
