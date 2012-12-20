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
    (renderer.render(text) || "").html_safe
  end

  def current_or_guest_user
    if current_user
      if session[:guest_user_id]
        if session[:guest_user_id] != current_user.id
          logging_in
#          guest_user.destroy
        end
        session[:guest_user_id] = nil
      end
      current_user
    else
      guest_user
    end
  end

  # find guest_user object associated with the current session,
  # creating one as needed
  def guest_user
    guest_id = session[:guest_user_id]
    if guest_id.nil? || User.find(guest_id).nil?
      user = create_guest_user
      session[:guest_user_id] = user.id
      return User.find(user.id)
    end
    User.find(guest_id)
  end

  def google_analytics_tag
    return '' unless Rails.env.production?
    return '' if is_admin?
    javascript_tag """
  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-5663087-8']);
  _gaq.push(['_setDomainName', '#{request.host}']);
  _gaq.push(['_setAllowLinker', true]);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

  $(function() {
    $('.tracked').click(function() {
      _gaq.push(['_link', $(this).attr('href')]);
      return false;
    });
  });

"""
  end

  def hittail_tag
    return '' unless Rails.env.production?
    return '' if is_admin?
    javascript_tag """
        (function(){ var ht = document.createElement('script');ht.async = true;
          ht.type='text/javascript';ht.src = '//96078.hittail.com/mlt.js';
          var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ht, s);})();
"""
  end

  def human_local_datetime(time, tz)
    time.in_time_zone(tz).strftime("%Y %b %d %l:%M %P")
  end

  def log_event(event, properties={})
    return if is_admin?

    return if request.user_agent =~ /\b(HttpClient|Baidu|Gigabot|Googlebot|libwww-perl|lwp-trivial|msnbot|SiteUptime|Slurp|WordPress|ZIBB|ZyBorg)\b/i

    distinct_id = properties.delete(:distinct_id) { |key| cookies.signed[:unique_id] }
    user_properties = {:distinct_id => distinct_id || ''}
    if user_signed_in?
      user_properties["mp_name_tag"]    = current_user.email || ''
      user_properties["$email"]         = current_user.email || ''
      user_properties["$created"]       = current_user.created_at || ''
      user_properties["$last_login"]    = current_user.last_sign_in_at || ''
      user_properties["$current_login"] = current_user.current_sign_in_at || ''
    end

    properties.merge!(user_properties)
    participating_ab_tests = Abingo.participating_tests rescue {}
    properties.merge!(participating_ab_tests)

    bingo!(event.dup)

    begin
      Delayed::Job.enqueue TrackerJob.new(
        event,
        request.env.slice("HTTP_X_FORWARDED_FOR", "REMOTE_ADDR"),
        properties,
        ENV['MIXPANEL_TOKEN']
      )
    rescue Exception => e
      NewRelic::Agent.notice_error(e, :custom_params => properties)
    end
  end

  def sign_up_button_text
    "Sign up now"
  end

  def tagline_text
   "Your online notebook. Keep a journal, take notes, organize ideas."
  end

end
