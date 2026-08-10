ActiveAdmin.register_page "Service Center Overview" do
  menu false

  content title: "ພາບລວມສູນບໍລິການ" do
    render partial: "active_admin/service_center_overview_content"
  end
end
