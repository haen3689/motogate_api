class Api::V1::PlateTypesController < ApiController
  skip_before_action :authenticate!

  def index
    data = PlateType.active.ordered.map do |pt|
      { plate_code: pt.plate_code, name: pt.name,
        color_class: pt.color_class, show_province: pt.show_province }
    end
    render_success(data)
  end
end
