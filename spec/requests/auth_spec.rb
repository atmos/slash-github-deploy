require "rails_helper"

RSpec.describe "Authentication", type: :request do
  before do
    OmniAuth.config.mock_auth[:slack]  = slack_omniauth_hash_for_atmos
    OmniAuth.config.mock_auth[:github] = github_omniauth_hash_for_atmos
    OmniAuth.config.mock_auth[:heroku] = heroku_omniauth_hash_for_atmos
  end

  def omniauth_url
    "http://www.example.com/"
  end

  def application_url
    "https://slack.com/apps/manage/A0QS72-slash-hubot-deploy"
  end

  it "requires a valid rails session" do
    get "/auth/slack"
    expect(status).to eql(302)
    expect(headers["Location"]).to eql("#{omniauth_url}auth/slack/callback")
    follow_redirect!

    # 302s to GitHub OAuth if Slack succeeds
    expect(status).to eql(302)
    expect(headers["Location"]).to eql("#{omniauth_url}auth/github?origin=")
    follow_redirect!

    # Calling back from GitHub's OAuth handshake
    expect(status).to eql(302)
    expect(headers["Location"]).to eql("#{omniauth_url}auth/github/callback")
    follow_redirect!

    # 302s to Heroku OAuth if Slack succeeds
    expect(status).to eql(302)
    expect(headers["Location"]).to eql("#{omniauth_url}auth/heroku?origin=")
    follow_redirect!

    # Calling back from Heroku's OAuth handshake
    expect(status).to eql(302)
    expect(headers["Location"]).to eql("#{omniauth_url}auth/heroku/callback")
    follow_redirect!

    expect(status).to eql(302)
    follow_redirect!

    # Redirect to Application in Slack App Store
    expect(status).to eql(302)
    expect(headers["Location"]).to eql(application_url)
  end

  it "preserves the origin parameter to redirect back to native apps" do
    origin = "slack://channel?team_id=T028&id=C028"
    encoded_origin = Base64.encode64(origin).chomp

    # Calling back from Slack's OAuth handshake
    get "/auth/slack?origin=#{encoded_origin}"
    expect(status).to eql(302)
    expect(headers["Location"]).to eql("#{omniauth_url}auth/slack/callback")
    follow_redirect!

    # 302s to GitHub OAuth if Slack succeeds
    expect(status).to eql(302)
    expect(headers["Location"])
      .to eql("#{omniauth_url}auth/github?origin=#{encoded_origin}")
    follow_redirect!

    # Calling back from GitHub's OAuth handshake
    expect(status).to eql(302)
    expect(headers["Location"]).to eql("#{omniauth_url}auth/github/callback")
    follow_redirect!

    # 302s to Heroku OAuth if Slack succeeds
    expect(status).to eql(302)
    expect(headers["Location"])
      .to eql("#{omniauth_url}auth/heroku?origin=#{encoded_origin}")
    follow_redirect!

    # Calling back from Heroku's OAuth handshake
    expect(status).to eql(302)
    expect(headers["Location"]).to eql("#{omniauth_url}auth/heroku/callback")
    follow_redirect!

    # Redirect to slack://channel
    expect(status).to eql(302)
    expect(headers["Location"]).to eql(origin)
  end
end
