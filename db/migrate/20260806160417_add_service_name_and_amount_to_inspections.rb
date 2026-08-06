class AddServiceNameAndAmountToInspections < ActiveRecord::Migration[8.1]
  def change
    add_column :inspections, :service_name, :string
    add_column :inspections, :amount, :decimal
  end
end
