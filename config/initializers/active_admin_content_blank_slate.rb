# Custom `index as: :content` pages render their own empty-state inside
# the partial (see e.g. _service_center_contracts_content.html.erb) —
# ActiveAdmin's default blank_slate ("No Foo found") otherwise replaces
# the *entire* custom page (header, filters, stat cards and all) the
# moment the underlying table has zero rows, which is exactly backwards
# for a page whose whole point is to keep working with zero data.
Rails.application.config.after_initialize do
  ActiveAdmin::Views::Pages::Index.prepend(Module.new do
    def items_in_collection?
      config[:as] == :content ? true : super
    end
  end)
end
