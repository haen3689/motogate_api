class Api::V1::NotificationsController < ApiController
  def index
    notifications = current_user.notifications.order(created_at: :desc)
    render_success(notifications.as_json)
  end

  def mark_read
    notification = current_user.notifications.find(params[:id])
    notification.update!(read: true)
    render_success({ message: "ອ່ານແລ້ວ" })
  rescue ActiveRecord::RecordNotFound
    render_error("ບໍ່ພົບການແຈ້ງເຕືອນ", status: :not_found)
  end

  def mark_all_read
    current_user.notifications.update_all(read: true)
    render_success({ message: "ອ່ານທັງໝົດແລ້ວ" })
  end
end
