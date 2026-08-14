class AdminRoadTaxesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "admin_road_taxes"
  end
end
