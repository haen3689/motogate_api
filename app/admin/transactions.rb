ActiveAdmin.register Transaction do
  menu priority: 4, if: -> { !current_admin_user.partner? && !current_admin_user.insurance? }

  actions :index, :show

  config.filters = false
  config.batch_actions = false

  index as: :content do
    render partial: "active_admin/transactions_content"
  end

  show do
    render partial: "active_admin/transaction_show_content"
  end

  controller do
    def scoped_collection
      super.includes(:user).order(created_at: :desc)
    end
  end
end
