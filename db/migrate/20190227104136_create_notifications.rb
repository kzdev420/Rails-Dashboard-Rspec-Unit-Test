class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :user_notifications do |t|
      t.integer :template
      t.references :user
      t.string :title
      t.text :text
      t.integer :status, default: 0
      t.timestamps
    end
  end
end
