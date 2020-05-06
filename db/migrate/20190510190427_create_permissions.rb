class CreatePermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :role_permissions do |t|
      t.references :role, foreign_key: true
      t.string :name
      t.boolean :record_create, default: false
      t.boolean :record_read, default: false
      t.boolean :record_update, default: false
      t.boolean :record_delete, default: false

      t.timestamps
    end

    add_index :role_permissions, [:name, :role_id], unique: true
  end
end
