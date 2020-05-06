class AddUserIdToVehicles < ActiveRecord::Migration[5.2]
  def change
    add_column :vehicles, :user_id, :integer, index: true
  end
end
