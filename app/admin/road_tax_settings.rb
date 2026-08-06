ActiveAdmin.register RoadTaxSetting do
  menu label: "ຄ່າທຳນຽມແພລດຟອມ", priority: 5

  actions :show, :edit, :update
  config.batch_actions = false

  permit_params :fee_type, :flat_amount, :percent_rate

  controller do
    def find_resource
      RoadTaxSetting.current
    end

    def show
      redirect_to edit_admin_road_tax_setting_path(resource)
    end
  end

  form do |f|
    f.inputs "ຄ່າທຳນຽມແພລດຟອມ (ສຳລັບການອັບໂຫລດຫຼັກຖານຈ່າຍນອກລະບົບ)" do
      f.input :fee_type, as: :select,
        collection: [['ຈຳນວນເງິນຄົງທີ່', 'flat'], ['ເປີເຊັນຂອງຄ່າທາງ', 'percent']],
        include_blank: false, label: "ຮູບແບບການຄິດໄລ່"
      f.input :flat_amount, label: "ຈຳນວນເງິນຄົງທີ່ (₭)", hint: "ໃຊ້ເມື່ອເລືອກ \"ຈຳນວນເງິນຄົງທີ່\""
      f.input :percent_rate, label: "ອັດຕາເປີເຊັນ (%)", hint: "ໃຊ້ເມື່ອເລືອກ \"ເປີເຊັນຂອງຄ່າທາງ\" — ຄິດຈາກລາຄາຄ່າທາງອ້າງອີງຂອງລົດຄັນນັ້ນ"
    end
    f.actions do
      f.action :submit, label: "ບັນທຶກ"
    end
  end
end
