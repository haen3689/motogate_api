class AdminInsurancesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "admin_insurances"
  end
end
