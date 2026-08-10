class Api::V1::ChatMessagesController < ApiController
  def index
    render_success(current_user.chat_messages.order(created_at: :asc).as_json)
  end

  def create
    msg = current_user.chat_messages.create!(sender: "user", body: params[:body])
    SupportCase.touch_for_user!(current_user)
    broadcast_to_admin(msg)
    render_success(msg.as_json, status: :created)
  rescue ActiveRecord::RecordInvalid => e
    render_error(e.message)
  end

  private

  # Live-updates the "ຫ້ອງສົນທະນາລູກຄ້າ" admin panel — best-effort, must
  # never fail the customer's message if the broadcast has trouble.
  def broadcast_to_admin(msg)
    ActionCable.server.broadcast("admin_chat", {
      user_id: current_user.id,
      user_phone: current_user.phone_number,
      user_name: [current_user.first_name, current_user.last_name].compact.join(" ").presence || current_user.name,
      message: msg.as_json
    })
  rescue => e
    Rails.logger.error("[Chat] Failed to broadcast to admin: #{e.message}")
  end
end
