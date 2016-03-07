applcation_url = ENV["SLACK_APP_URL"] || "https://github.com/atmos/slash-hubot-deploy"

Rails.application.routes.draw do
  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
  get  "/auth/failure"         => "sessions#destroy"
  get  "/auth/slack/callback"  => "sessions#create_slack"
  get  "/auth/github/callback" => "sessions#create_github"
  get  "/auth/heroku/callback" => "sessions#create_heroku"

  get  "/boomtown"             => "application#boomtown"
  post "/commands"             => "commands#create"
  post "/signout"              => "sessions#destroy"

  root to: redirect(applcation_url, status: 302)
end
