require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SlashGithubDeploy
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end

    config.active_job.queue_adapter = :sidekiq

    config.lograge.enabled = true
    config.lograge.custom_options = lambda do |event|
      { request_id: event.payload[:request_id] }
    end

    config.generators do |g|
      g.assets = false
      g.helper = false
      g.view_specs = false
    end
  end
end
