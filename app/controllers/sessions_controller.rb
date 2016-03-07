# Session controller for authenticating users with GitHub/Heroku/Hipchat
class SessionsController < ApplicationController
  # rubocop:disable Metrics/AbcSize
  def create_slack
    user = User.find_or_initialize_by(slack_user_id: omniauth_info_user_id)
    user.slack_user_name   = omniauth_info["info"]["user"]
    user.slack_team_id     = omniauth_info["info"]["team_id"]

    user.save
    session[:user_id] = user.id
    redirect_to after_successful_slack_user_setup_path
  end

  def create_github
    user = User.find(session[:user_id])
    user.github_token = omniauth_info["credentials"]["token"]
    user.save
    redirect_to after_successful_github_user_setup_path
  rescue ActiveRecord::RecordNotFound
    redirect_to "/auth/slack"
  end

  def create_heroku
    user = User.find(session[:user_id])
    user.heroku_uuid  = omniauth_info["uid"]
    user.heroku_email = omniauth_info["info"]["email"]
    user.heroku_token = omniauth_info["credentials"]["token"]
    user.heroku_refresh_token = omniauth_refresh_token
    user.heroku_expires_at    = omniauth_expiration
    user.save
    redirect_to after_successful_heroku_user_setup_path
  rescue ActiveRecord::RecordNotFound
    redirect_to "/auth/slack"
  end

  def destroy
    session.clear
    redirect_to root_url, notice: "Signed out!"
  end

  private

  def after_successful_heroku_user_setup_path
    if omniauth_origin
      Base64.decode64(omniauth_origin)
    else
      root_url
    end
  rescue
    root_url
  end

  def after_successful_github_user_setup_path
    "/auth/heroku?origin=#{omniauth_origin}"
  end

  def after_successful_slack_user_setup_path
    "/auth/github?origin=#{omniauth_origin}"
  end

  def omniauth_origin
    request.env["omniauth.origin"]
  end

  def omniauth_info_user_id
    omniauth_info["info"]["user_id"]
  end

  def omniauth_refresh_token
    omniauth_info["credentials"]["refresh_token"]
  end

  def omniauth_expiration
    Time.at(omniauth_info["credentials"]["expires_at"]).utc
  end

  def omniauth_info
    request.env["omniauth.auth"]
  end
end
