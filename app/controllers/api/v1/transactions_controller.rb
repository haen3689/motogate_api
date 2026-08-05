class Api::V1::TransactionsController < ApiController
  def index
    transactions = current_user.transactions.order(created_at: :desc)
    render_success(transactions.as_json)
  end

  def show
    transaction = current_user.transactions.find(params[:id])
    render_success(transaction.as_json)
  rescue ActiveRecord::RecordNotFound
    render_error("ບໍ່ພົບທຸລະກຳ", status: :not_found)
  end
end
