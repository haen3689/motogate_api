require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Set to false in production to prevent leaking sensitive debugging details to users
  config.consider_all_requests_local = false

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Change to "debug" to log everything (including potentially personally-identifiable information!).
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Use memory store to bypass solid_cache database dependency on Render
  config.cache_store = :memory_store

  # Switch queue adapter to :async to avoid Solid Queue DB requirements
  config.active_job.queue_adapter = :async

  # Enable locale fallbacks for I18n
  config.i18n.fallbacks = true

  # Disable active storage variant processor if image_processing gem is not installed
  config.active_storage.variant_processor = :disabled

  # Configure Active Storage service for production
  config.active_storage.service = :local
end