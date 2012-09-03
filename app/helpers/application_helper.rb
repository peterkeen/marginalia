module ApplicationHelper
  
  def is_guest?
    ! session[:guest_user_id].nil?
  end

  def is_admin?
    user_signed_in? && current_user.is_admin
  end

  def markdown
    text = capture do
      yield
    end
    renderer = Redcarpet::Markdown.new(
      RenderWithTags.new(:no_sanitize => true),
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

  def google_analytics_tag
    return '' unless Rails.env.production?
    javascript_tag """
  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-5663087-8']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

"""
  end

  def human_local_datetime(time, tz)
    time.in_time_zone(tz).strftime("%Y %b %d %l:%M %P")
  end

  def log_event(event, properties={})
    return if is_admin?

    distinct_id = properties.delete(:distinct_id) { |key| cookies.secure[:unique_id] }
    user_properties = {:distinct_id => distinct_id}
    if user_signed_in?
      user_properties["$email"]         = current_user.email
      user_properties["$created"]       = current_user.created_at
      user_properties["$last_login"]    = current_user.last_sign_in_at
      user_properties["$current_login"] = current_user.current_sign_in_at
    end

    properties.merge!(user_properties)
    
    Delayed::Job.enqueue TrackerJob.new(
      :event => event,
      :request_env => request.env,
      :properties => properties
    )
  end

end
