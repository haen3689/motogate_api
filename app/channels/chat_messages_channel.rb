class ChatMessagesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:user_id]}"
  end
end
