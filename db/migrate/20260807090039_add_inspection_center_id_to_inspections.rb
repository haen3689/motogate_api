class AddInspectionCenterIdToInspections < ActiveRecord::Migration[8.1]
  def up
    add_reference :inspections, :inspection_center, foreign_key: true

    # Backfill: existing bookings only stored a denormalized center_name
    # string. Link them to the real center where the name matches exactly,
    # so partner accounts can be scoped by inspection_center_id going
    # forward. Any that don't match (renamed/deleted centers) are left
    # nil — same as before, just not partner-visible.
    InspectionCenter.reset_column_information
    Inspection.reset_column_information
    InspectionCenter.find_each do |center|
      Inspection.where(center_name: center.name, inspection_center_id: nil)
                .update_all(inspection_center_id: center.id)
    end
  end

  def down
    remove_reference :inspections, :inspection_center, foreign_key: true
  end
end
