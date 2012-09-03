class TrackerJob < Struct.new(:event, :request_env, :properties)
  def perform
    return unless ENV['MIXPANEL_TOKEN']
    mp = Mixpanel::Tracker.new(ENV['MIXPANEL_TOKEN'], request_env)
    mp.track_event(event, properties)
  end
end
