module ActivityLogging
  extend ActiveSupport::Concern

  included do
    after_action :log_activity
  end

  private

  def log_activity
    return unless %w[create update destroy].include?(action_name)
    return unless response.redirect?
    return unless current_admin_user
    return unless respond_to?(:resource, true)

    obj = send(:resource)
    return unless obj

    action =
      case params[:action]
      when "create"  then "created"
      when "update"  then "updated"
      when "destroy" then "deleted"
      end
    return unless action

    label = activity_log_label_for(obj)

    ActivityLog.create!(
      admin_user: current_admin_user,
      action: action,
      resource_type: obj.class.name,
      resource_id: obj.id,
      resource_label: label.to_s.truncate(120)
    )
  rescue => e
    Rails.logger.error("[ActivityLog] Failed to log activity: #{e.message}")
  end

  def activity_log_label_for(obj)
    if obj.respond_to?(:name) && obj.name.present?
      obj.name
    elsif obj.respond_to?(:title) && obj.title.present?
      obj.title
    elsif obj.respond_to?(:plate_number) && obj.plate_number.present?
      obj.plate_number
    elsif obj.respond_to?(:email) && obj.email.present?
      obj.email
    else
      "##{obj.id}"
    end
  end
end
