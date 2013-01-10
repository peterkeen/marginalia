class TrackerJob < Struct.new(:event, :request_env, :properties, :token)
  def perform
    return unless token
    mp = Mixpanel::Tracker.new(token, request_env)
    mp.track(event, properties)
  end
end
