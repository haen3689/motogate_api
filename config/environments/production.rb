
require "active_support/core_ext/integer/time"

Rails.application.configure do
  # ============================================================
  # Production Configuration
  # Rails + PostgreSQL + Render
  # ============================================================

  # ------------------------------------------------------------
  # Code loading
  # ------------------------------------------------------------

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance.
  config.eager_load = true


  # ------------------------------------------------------------
  # Error handling
  # ------------------------------------------------------------

  # Do not show detailed error pages to users in production.
  config.consider_all_requests_local = false


  # ------------------------------------------------------------
  # Static files / Assets
  # ------------------------------------------------------------

  # Cache assets for 1 year.
  config.public_file_server.headers = {
    "cache-control" => "public, max-age=#{1.year.to_i}"
  }


  # ------------------------------------------------------------
  # SSL
  # ------------------------------------------------------------

  # Render provides HTTPS.
  #
  # Keep these disabled during initial testing if necessary.
  # Once your deployment is working correctly, you can enable them.
  #
  # config.assume_ssl = true
  # config.force_ssl = true


  # ------------------------------------------------------------
  # Logging
  # ------------------------------------------------------------

  # Log to STDOUT so Render can display logs.
  config.log_tags = [:request_id]

  config.logger = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Log level can be controlled with RAILS_LOG_LEVEL.
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")


  # ------------------------------------------------------------
  # Health check
  # ------------------------------------------------------------

  # Prevent health checks from filling the logs.
  config.silence_healthcheck_path = "/up"


  # ------------------------------------------------------------
  # Active Support
  # ------------------------------------------------------------

  # Disable deprecation logging.
  config.active_support.report_deprecations = false

  # Enable I18n locale fallbacks.
  config.i18n.fallbacks = true


  # ------------------------------------------------------------
  # Cache
  # ------------------------------------------------------------

  # Use memory cache.
  #
  # This avoids requiring Solid Cache database configuration
  # during the first Render deployment.
  config.cache_store = :memory_store


  # ------------------------------------------------------------
  # Active Job
  # ------------------------------------------------------------

  # Use Async adapter.
  #
  # This is suitable for initial deployment/testing on Render.
  # It does not require Solid Queue infrastructure.
  config.active_job.queue_adapter = :async


  # ------------------------------------------------------------
  # Active Record / Database
  # ------------------------------------------------------------

  # Do not automatically dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only show ID when inspecting Active Record objects.
  config.active_record.attributes_for_inspect = [:id]


  # ------------------------------------------------------------
  # Active Storage
  # ------------------------------------------------------------

  # Disable image variants if image_processing is not installed.
  config.active_storage.variant_processor = :disabled

  # Local storage for initial testing.
  #
  # IMPORTANT:
  # Render's filesystem should NOT be treated as permanent storage
  # for production documents/images.
  #
  # For production, move this to S3-compatible object storage.
  config.active_storage.service = :local


  # ------------------------------------------------------------
  # Security / Host Authorization
  # ------------------------------------------------------------

  # Leave this commented during initial Render testing.
  #
  # When you have your real domain, configure it here:
  #
  # config.hosts = [
  #   "yourdomain.com",
  #   /.*\.yourdomain\.com/
  # ]


  # ------------------------------------------------------------
  # Optional SSL health-check configuration
  # ------------------------------------------------------------

  # If force_ssl is enabled later, you can exclude /up:
  #
  # config.ssl_options = {
  #   redirect: {
  #     exclude: ->(request) {
  #       request.path == "/up"
  #     }
  #   }
  # }
end

