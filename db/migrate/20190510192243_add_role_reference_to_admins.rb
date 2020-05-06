class AddRoleReferenceToAdmins < ActiveRecord::Migration[5.2]
  def change
    add_reference :admins, :role, foreign_key: true
    remove_column :admins, :role, :string
  end
end
