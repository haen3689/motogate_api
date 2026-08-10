class AdminChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "admin_chat"
  end
end
