class CreateSupportCases < ActiveRecord::Migration[8.1]
  def change
    create_table :support_cases do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.references :admin_user, null: true, foreign_key: true
      t.string :status, null: false, default: "open"
      t.datetime :last_message_at
      t.datetime :resolved_at
      t.integer :rating
      t.text :feedback_comment

      t.timestamps
    end

    add_index :support_cases, :status
  end
end
