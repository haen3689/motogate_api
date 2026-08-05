# Override ActiveAdmin's Arbre page renderer.
# Replaces the default horizontal navbar with two separate partials:
#   _sidebar.html.erb  →  left navigation  (like sidebar.php in PHP demo)
#   _navbar.html.erb   →  top bar          (like header.php in PHP demo)
Rails.application.config.after_initialize do
  ActiveAdmin::Views::Pages::Base.prepend(Module.new do
    def build_page
      within body(class: body_classes) do
        text_node helpers.render(partial: "active_admin/sidebar")

        div id: "wrapper" do
          build_unsupported_browser
          text_node helpers.render(partial: "active_admin/header")

          build_page_content
          footer active_admin_namespace
        end
      end
    end
  end)
end
