require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports disabled for security in production
  config.consider_all_requests_local = false

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Change to "debug" to log everything
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Use memory store to bypass solid_cache database dependency
  config.cache_store = :solid_cache_store

  # Active Job Adapter.
  #
  # This ran Solid Queue inside Puma (SOLID_QUEUE_IN_PUMA), which forks a
  # supervisor, a dispatcher and a worker — three additional processes, each a
  # full copy of a Rails app that also loads ActiveAdmin — plus a worker
  # polling the queue database ten times a second. All of that existed to run
  # exactly one job: SendOtpSmsJob, enqueued from a single place. On a 512MB
  # instance that infrastructure is a large part of why the container keeps
  # being OOM-killed.
  #
  # :async keeps perform_later non-blocking (the reason the SMS was moved off
  # the request in the first place) using a thread pool inside the web process,
  # with no extra processes and no queue database. The trade-off is that a job
  # still in the queue when the process restarts is lost — acceptable for a
  # fire-and-forget OTP the user can simply request again, and strictly better
  # than the whole API dying every hour.
  #
  # Revisit when there are jobs that must survive a restart or need retries:
  # move Solid Queue to its own Render Background Worker service rather than
  # putting it back inside Puma.
  config.active_job.queue_adapter = :async

  # Enable locale fallbacks for I18n
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]

  # Disable active storage variant processor if image_processing gem is not installed
  config.active_storage.variant_processor = :disabled
  
  # Configure Active Storage service for production.
  #
  # IMPORTANT: this must NOT be :local. Render's filesystem is ephemeral —
  # a fresh container is built on every deploy, so anything written to
  # local disk (uploaded photos, registration books, etc.) is wiped out
  # the next time this app is deployed. Cloudflare R2 is S3-compatible
  # object storage that persists independently of the app container.
  config.active_storage.service = :cloudflare_r2
end