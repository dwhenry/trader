Bugsnag.configure do |config|
  config.api_key = '3895f7a57078be5748188c6c6e816a61'
  if Rails.env.development?
    config.auto_notify = false
  end
end
