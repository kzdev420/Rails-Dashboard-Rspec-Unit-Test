class CreateAdminRights < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_rights, id: false do |t|
      t.references :subject, index: true, polymorphic: true
      t.integer :admin_id, index: true
    end
  end
end
