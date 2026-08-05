ActiveAdmin.register OnboardingSlide do
  menu label: "Onboarding Slides", priority: 10

  permit_params :title, :subtitle, :image_url, :position, :active

  index do
    selectable_column
    id_column
    column("ລຳດັບ")  { |s| s.position }
    column("ຫົວຂໍ້") { |s| s.title }
    column("ຄຳອະທິບາຍ") { |s| s.subtitle }
    column("ຮູບພາບ") do |s|
      if s.image_url.present?
        image_tag s.image_url, style: "height:48px; border-radius:6px;"
      else
        status_tag "ບໍ່ມີຮູບ", class: "no"
      end
    end
    column("ສະຖານະ") do |s|
      status_tag s.active ? "ເປີດໃຊ້" : "ປິດ", class: s.active ? "yes" : "no"
    end
    column :updated_at
    actions
  end

  filter :title
  filter :active

  show do
    attributes_table do
      row("ລຳດັບ")       { |s| s.position }
      row("ຫົວຂໍ້")      { |s| s.title }
      row("ຄຳອະທິບາຍ")  { |s| s.subtitle }
      row("URL ຮູບພາບ")  { |s| s.image_url.presence || "—" }
      row("ຮູບພາບ") do |s|
        image_tag s.image_url, style: "max-width:300px; border-radius:12px;" if s.image_url.present?
      end
      row("ສະຖານະ") do |s|
        status_tag s.active ? "ເປີດໃຊ້" : "ປິດ", class: s.active ? "yes" : "no"
      end
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs "Onboarding Slide" do
      f.input :position,  label: "ລຳດັບ (0 = ທຳອິດ)", hint: "ເລກນ້ອຍສຸດຈະສະແດງກ່ອນ"
      f.input :title,     label: "ຫົວຂໍ້"
      f.input :subtitle,  label: "ຄຳອະທິບາຍ", as: :text, input_html: { rows: 3 }
      f.input :image_url, label: "URL ຮູບພາບ", hint: "ຖ້າບໍ່ມີ ແອັບຈະສະແດງ icon ແທນ"
      f.input :active,    label: "ເປີດໃຊ້ງານ"
    end
    f.actions
  end
end
