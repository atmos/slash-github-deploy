# A user from the Slack API
class User < ApplicationRecord
  include TokenManagement

  has_many :commands, dependent: :destroy

  def heroku_api
    @heroku_api ||= HerokuApi.new(heroku_token)
  end

  def heroku_user_information
    return nil unless heroku_configured?
    heroku_api.user_information
  end

  def create_command_for(params)
    command = commands.create(
      channel_id: params[:channel_id],
      channel_name: params[:channel_name],
      command: params[:command],
      command_text: params[:text],
      response_url: params[:response_url],
      team_id: params[:team_id],
      team_domain: params[:team_domain]
    )
    CommandExecutorJob.perform_later(command_id: command.id)
    command
  end
end
