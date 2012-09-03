class TrackerJob < Struct.new(:event, :request_env, :properties)
  def perform
    mp = Mixpanel::Tracker.new(ENV['MIXPANEL_TOKEN', request_env)
    mp.track_event(event, properties)
  end
end
