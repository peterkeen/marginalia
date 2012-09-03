class TrackerJob < Struct.new(:event, :request_env, :properties, :token)
  def perform
    p event
    p request_env
    p properties
    p token
    return unless token
    mp = Mixpanel::Tracker.new(token, request_env)
    mp.track_event(event, properties)
  end
end
