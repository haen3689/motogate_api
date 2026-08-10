class Api::V1::PartnerApplicationsController < ApiController
  skip_before_action :authenticate!, only: %i[create]

  def create
    application = PartnerApplication.new(application_params)
    if application.save
      render_success(application.as_json(only: %i[id business_name service_type status created_at]), status: :created)
    else
      render_error(application.errors.full_messages.join(", "))
    end
  end

  private

  def application_params
    params.permit(:business_name, :service_type, :owner_name, :phone, :location)
  end
end
