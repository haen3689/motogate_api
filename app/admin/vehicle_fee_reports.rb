ActiveAdmin.register_page "Vehicle Fee Reports" do
  menu label: "ລາຍງານຊຳລະຄ່າທຳນຽມ", priority: 4, if: -> { !current_admin_user.partner? && !current_admin_user.insurance? }

  content title: "ລາຍງານຄ່າທຳນຽມແພລດຟອມ" do
    render partial: "active_admin/vehicle_fee_reports_content"
  end
end
