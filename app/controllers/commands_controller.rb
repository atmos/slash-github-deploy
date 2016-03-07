# Endpoint for handling slack postings
class CommandsController < ApplicationController
  protect_from_forgery with: :null_session
  def create
    if slack_token_valid?
      if current_user
        current_user.create_command_for(params)
        render json: { response_type: "in_channel" }.to_json
      else
        render json: authenticate_payload.to_json
      end
    else
      render json: {}, status: 404
    end
  end

  private

  def current_user
    @current_user ||= User.find_by(slack_user_id: params[:user_id],
                                   slack_team_id: params[:team_id])
  end

  def slack_token
    ENV["SLACK_SLASH_COMMAND_TOKEN"]
  end

  def slack_token_valid?
    ActiveSupport::SecurityUtils.secure_compare(params[:token], slack_token)
  end

  def slack_login_uri
    uri = "slack://channel?team=#{params[:team_id]}&id=#{params[:channel_id]}"
    "#{request.base_url}/auth/slack?origin=#{Base64.encode64(uri).chomp}"
  end

  def authenticate_payload
    {
      response_type: "in_channel",
      text: "Please <#{slack_login_uri}|sign in> to use this feature."
    }
  end
end
