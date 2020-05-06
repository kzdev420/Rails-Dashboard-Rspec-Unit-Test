class AddPhoneCreatorIdToAdmins < ActiveRecord::Migration[5.2]
  def change
    add_column :admins, :phone, :string
    add_column :admins, :avatar, :string
    add_column :admins, :creator_id, :integer, index: true
    add_column :admins, :name, :string
    add_column :admins, :status, :integer, default: 0
  end
end
