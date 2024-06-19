require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RailsRuby3
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Create a logger with a file as a logging target
    config.logger = Logger.new(Rails.root.join('log', 'important.log'), 'daily')
    # Set the minimum log level
    config.log_level = :info
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.action_dispatch.default_headers = {
      'X-Frame-Options' => 'ALLOWFROM replit.com'
    }
  end

end
