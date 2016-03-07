# A command a Slack User issued
class Command < ApplicationRecord
  belongs_to :user

  before_validation :extract_cli_args, on: :create

  def run
    Rails.logger.info "Running command #{id}"
  end

  def description
    if application
      "Running(#{id}): '#{task}:#{subtask}' for #{application}..."
    else
      "Running(#{id}): '#{task}:#{subtask}'..."
    end
  end

  def default_response
    { text: description, response_type: "in_channel" }
  end

  private

  def postback_message(message)
    response = client.post do |request|
      request.url callback_uri.path
      request.body = message.to_json
      request.headers["Content-Type"] = "application/json"
    end

    Rails.logger.info JSON.parse(response.body)
  rescue StandardError => e
    Rails.logger.info "Unable to post back to slack: '#{e.inspect}'"
  end

  def callback_uri
    @callback_uri ||= Addressable::URI.parse(response_url)
  end

  def client
    @client ||= Faraday.new(url: "https://hooks.slack.com")
  end

  def extract_cli_args
    self.subtask = "default"

    match = command_text.match(/-a ([-_\.0-9a-z]+)/)
    self.application = match[1] if match

    match = command_text.match(/^([-_\.0-9a-z]+)(?:\:([^\s]+))/)
    if match
      self.task    = match[1]
      self.subtask = match[2]
    end

    match = command_text.match(/^([-_\.0-9a-z]+)\s*/)
    self.task = match[1] if match
  end
end
