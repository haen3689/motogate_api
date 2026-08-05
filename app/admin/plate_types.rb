ActiveAdmin.register PlateType do
  menu parent: false, if: -> { false }

  config.batch_actions = false
  config.filters = false

  permit_params :plate_code, :name, :color_class, :show_province, :status, :position

  index title: false, download_links: false do
    render partial: "active_admin/plate_types_content"
  end

  # ซ่อน new/show page — ทุกอย่างอยู่ใน index
  config.clear_action_items!

  controller do
    def show
      redirect_to admin_plate_types_path
    end

    def new
      redirect_to admin_plate_types_path
    end

    def create
      @plate_type = PlateType.new(permitted_params[:plate_type])
      if @plate_type.save
        redirect_to admin_plate_types_path, notice: "ເພີ່ມປ້າຍ #{@plate_type.plate_code} ສຳເລັດແລ້ວ"
      else
        redirect_to admin_plate_types_path, alert: @plate_type.errors.full_messages.join(", ")
      end
    end

    def edit
      redirect_to admin_plate_types_path
    end

    def update
      @plate_type = PlateType.find(params[:id])
      if @plate_type.update(permitted_params[:plate_type])
        redirect_to admin_plate_types_path, notice: "ອັບເດດປ້າຍ #{@plate_type.plate_code} ສຳເລັດແລ້ວ"
      else
        redirect_to admin_plate_types_path, alert: @plate_type.errors.full_messages.join(", ")
      end
    end

    def destroy
      @plate_type = PlateType.find(params[:id])
      code = @plate_type.plate_code
      @plate_type.destroy
      redirect_to admin_plate_types_path, notice: "ລົບປ້າຍ #{code} ສຳເລັດແລ້ວ"
    end
  end
end
