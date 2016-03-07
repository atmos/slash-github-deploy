require "rails_helper"

RSpec.describe "SlashGitHubDeploy /commands", type: :request do
  before do
  end

  def default_params(options = {})
    command_params_for("").merge(
      token: "secret-slack-token",
      user_id: "U123YG08X",
      user_name: "atmos"
    ).merge(options)
  end

  it "links to login + origin if you need to authenticate" do
    post "/commands", params: default_params(text: "ps")

    origin = "slack://channel?team=T123YG08V&id=C99NNAY74"
    encoded_origin = Base64.encode64(origin).chomp

    expect(status).to eql(200)
    response_body = JSON.parse(body)
    expect(response_body["response_type"]).to eql("in_channel")
    link = "Please <http://www.example.com/auth/slack?origin=" \
           "#{encoded_origin}|sign in> to use this feature."
    expect(response_body["text"]).to eql(link)
  end

  it "404s if the incoming command isn't from slack" do
    post "/commands", params: default_params(token: "rando-token", text: "ps")

    expect(status).to eql(404)
    response_body = JSON.parse(body)
    expect(response_body).to eql({})
  end
end
