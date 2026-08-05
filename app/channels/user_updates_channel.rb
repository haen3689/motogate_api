class UserUpdatesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "user_updates"
  end
end
