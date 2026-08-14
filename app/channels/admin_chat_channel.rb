class AdminChatChannel < ApplicationCable::Channel
  # Carries every support message body along with the sender's phone number,
  # and was joinable by anyone who could open a WebSocket. Staff only.
  def subscribed
    return reject unless current_admin

    stream_from "admin_chat"
  end
end
