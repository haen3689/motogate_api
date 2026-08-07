class AdminInspectionsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "admin_inspections"
  end
end
