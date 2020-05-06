class CreateAttrPermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :role_permission_attributes do |t|
      t.references :permission, foreign_key: { to_table: :role_permissions }
      t.string :name
      t.boolean :attr_read, default: false
      t.boolean :attr_update, default: false

      t.timestamps
    end

    add_index :role_permission_attributes, [:name, :permission_id], unique: true
  end
end
