ENV['GOOGLE_CLIENT_ID'] = '426724436350-7dtph5lia0qmdjqu7n9982rr22cg428j.apps.googleusercontent.com'
ENV['GOOGLE_CLIENT_SECRET'] = 'JoQQ9QNJIU1Z1bUg7Jafu35m'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET']
end
