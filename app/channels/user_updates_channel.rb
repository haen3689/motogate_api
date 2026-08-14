class UserUpdatesChannel < ApplicationCable::Channel
  # Was a single global "user_updates" stream that every subscriber joined
  # unconditionally, so one user's profile update — including their ID number,
  # licence number and signed document URLs — was delivered to everyone who
  # could open a WebSocket.
  #
  # Two legitimate audiences, so two streams:
  #   - the owner, who gets only their own updates
  #   - ActiveAdmin's header (see app/views/active_admin/_header.html.erb),
  #     which toasts on any user's edit and needs the firehose — but only for
  #     an authenticated admin
  # Api::V1::AuthController#profile publishes to both.
  def subscribed
    if current_admin
      stream_from "admin_user_updates"
    elsif current_user
      stream_from "user_updates_#{current_user.id}"
    else
      reject
    end
  end
end
