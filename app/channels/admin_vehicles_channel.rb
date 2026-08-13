class AdminVehiclesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "admin_vehicles"
  end
end
