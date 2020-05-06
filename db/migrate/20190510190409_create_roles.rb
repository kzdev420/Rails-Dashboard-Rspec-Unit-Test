class CreateRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :roles do |t|
      t.string :name, index: { unique: true }
      t.boolean :full, default: false

      t.timestamps
    end
  end
end
