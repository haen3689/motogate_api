# Generic read/poll endpoint for any Payment, regardless of what it's paying
# for (RoadTax, Insurance, ...). Creation happens inside each payable's own
# controller (e.g. RoadTaxesController#create) since only that controller
# knows how to authorize and price its own resource — this controller only
# needs to know how to check payable ownership generically.
class Api::V1::PaymentsController < ApiController
  def show
    payment = Payment.find_by!(uuid: params[:id])
    raise ActiveRecord::RecordNotFound unless owned_by_current_user?(payment)

    render_success(payment.as_app_json)
  rescue ActiveRecord::RecordNotFound
    render_error("ບໍ່ພົບຂໍ້ມູນການຊຳລະເງິນ", status: :not_found)
  end

  private

  def owned_by_current_user?(payment)
    payable = payment.payable
    payable.respond_to?(:payment_owner) && payable.payment_owner == current_user
  end
end
