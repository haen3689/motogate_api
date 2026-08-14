class ChatMessagesChannel < ApplicationCable::Channel
  # Streamed from "chat_#{params[:user_id]}" — a raw, unvalidated parameter, so
  # any client could name someone else's id and read their support conversation
  # with the agent. The stream is now derived from the authenticated connection
  # and the parameter is ignored entirely.
  def subscribed
    return reject unless current_user

    stream_from "chat_#{current_user.id}"
  end
end
