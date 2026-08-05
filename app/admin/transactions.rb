ActiveAdmin.register Transaction do
  menu priority: 4

  actions :index, :show

  index do
    selectable_column
    id_column
    column :user do |t| link_to t.user.phone_number, admin_user_path(t.user) end
    column :transaction_type
    column :amount do |t| number_to_currency(t.amount, unit: "LAK ", separator: ".", delimiter: ",") end
    column :status do |t| status_tag t.status, class: t.status end
    column :reference
    column :created_at
    actions
  end

  filter :transaction_type, as: :select, collection: Transaction::TYPES
  filter :status, as: :select, collection: Transaction::STATUSES
  filter :created_at

  show do
    attributes_table do
      row :id
      row :user do |t| link_to t.user.phone_number, admin_user_path(t.user) end
      row :transaction_type
      row :amount do |t| number_to_currency(t.amount, unit: "LAK ", separator: ".", delimiter: ",") end
      row :status do |t| status_tag t.status end
      row :reference
      row :description
      row :created_at
    end
  end
end
