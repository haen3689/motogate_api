ActiveAdmin.register Payment do
  menu label: "ການຊຳລະເງິນ", priority: 6

  actions :index, :show
  config.batch_actions = false
  config.filters = [:status, :provider, :terminal_id, :payable_type, :uuid, :bcel_transaction_id, :created_at]

  scope :all, default: true
  scope("ລໍຖ້າ") { |s| s.where(status: "pending") }
  scope("ຊຳລະແລ້ວ") { |s| s.where(status: "paid") }

  index do
    selectable_column
    column("ອ້າງອີງ") { |p| p.bcel_transaction_id.presence || p.uuid }
    column :payable_type
    column("ຈ່າຍສຳລັບ") { |p| p.payable&.payment_owner&.phone_number }
    column :terminal_id
    column :amount
    column :status do |p|
      status_tag p.status,
                 class: { "pending" => "warning", "paid" => "ok", "expired" => "error", "failed" => "error" }[p.status]
    end
    column :paid_at
    column :created_at
    actions
  end

  show do
    attributes_table do
      row("ອ້າງອີງ BCEL") { resource.bcel_transaction_id.presence || "—" }
      row(:uuid)
      row(:invoice_id)
      row :payable_type
      row("ຈ່າຍໂດຍ") { resource.payable&.payment_owner&.phone_number }
      row :terminal_id
      row :description
      row :amount
      row :ccy
      row :status
      row :ticket
      row :fccref
      row :payer_name
      row :payer_phone
      row :expires_at
      row :paid_at
      row :created_at
      row :updated_at
    end
  end
end
