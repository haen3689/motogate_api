class RenameColumnsForeignKeys < ActiveRecord::Migration[8.1]
  def change
    rename_column :inspection_services, :center_id,  :inspection_center_id
    rename_column :insurance_packages,  :company_id, :insurance_company_id
  end
end
