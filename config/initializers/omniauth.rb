Rails.application.config.middleware.use OmniAuth::Builder do
  provider :slack, ENV["SLACK_OAUTH_ID"], ENV["SLACK_OAUTH_SECRET"], scope: "identify,commands"
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV["GITHUB_OAUTH_ID"], ENV["GITHUB_OAUTH_SECRET"], scope: "user,repo"
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :heroku, ENV["HEROKU_OAUTH_ID"], ENV["HEROKU_OAUTH_SECRET"], scope: "global", fetch_info: true
end
