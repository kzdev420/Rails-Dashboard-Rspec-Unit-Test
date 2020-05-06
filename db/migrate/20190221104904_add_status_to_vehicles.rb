class AddStatusToVehicles < ActiveRecord::Migration[5.2]
  def change
    add_column :vehicles, :status, :integer, status: 0 # typo, fixed in new migration
  end
end
