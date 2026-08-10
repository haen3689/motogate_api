ActiveAdmin.register OnboardingSlide do
  menu label: "Onboarding Slides", priority: 10, if: -> { !current_admin_user.partner? && !current_admin_user.insurance? }

  permit_params :title, :subtitle, :image_url, :position, :active

  config.filters = false
  config.batch_actions = false

  index as: :content do
    render partial: "active_admin/onboarding_slides_content"
  end

  show do
    render partial: "active_admin/onboarding_slide_show_content"
  end

  form partial: "active_admin/onboarding_slide_form_content"
end
