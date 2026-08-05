Ransack.configure do |config|
  # ignore stale/unknown ransack params from session or URL
  # instead of raising NoMethodError
  config.ignore_unknown_conditions = true
end
