class Api::V1::TransactionsController < ApiController
  def index
    transactions = current_user.transactions.includes(:payment).order(created_at: :desc)
    render_success(transactions.map { |t| transaction_json(t) })
  end

  def show
    transaction = current_user.transactions.find(params[:id])
    render_success(transaction_json(transaction))
  rescue ActiveRecord::RecordNotFound
    render_error("ບໍ່ພົບທຸລະກຳ", status: :not_found)
  end

  private

  def transaction_json(t)
    t.as_json.merge(t.payment_refs)
  end
end
