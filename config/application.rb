require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CoverTracker
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    #
    config.load_defaults 6.1

    # Pod time (R.I.P. the Pod).
    #
    config.time_zone = 'Eastern Time (US & Canada)'

    # Users may upload very large WAV files, so we should give them lots of time
    # to upload them.
    #
    config.active_storage.service_urls_expire_in = 1.hour

    # Use VIPS for processing image transformations.
    #
    config.active_storage.variant_processor = :vips
  end
end
