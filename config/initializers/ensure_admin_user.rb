Rails.application.config.after_initialize do
  if ActiveRecord::Base.connection.table_exists?("admin_users")
    admin = AdminUser.find_or_initialize_by(email: "admin@example.com")
    admin.password = "password"
    admin.password_confirmation = "password"
    admin.role = "admin"
    if admin.save
      Rails.logger.info("Default AdminUser (admin@example.com) successfully initialized/updated.")
    else
      Rails.logger.error("Failed to save AdminUser: #{admin.errors.full_messages.join(', ')}")
    end
  end
rescue => e
  Rails.logger.error("Error in ensure_admin_user initializer: #{e.message}")
end
