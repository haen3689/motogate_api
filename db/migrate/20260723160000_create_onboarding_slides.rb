class CreateOnboardingSlides < ActiveRecord::Migration[8.1]
  def change
    create_table :onboarding_slides do |t|
      t.string  :title,     null: false
      t.text    :subtitle,  null: false
      t.string  :image_url
      t.integer :position,  null: false, default: 0
      t.boolean :active,    null: false, default: true

      t.timestamps
    end
  end
end
