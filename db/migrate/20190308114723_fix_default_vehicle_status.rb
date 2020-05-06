class FixDefaultVehicleStatus < ActiveRecord::Migration[5.2]
  def up
    change_column :vehicles, :status, :integer, default: 0
    Vehicle.update_all(status: 0)
  end

  def down
    change_column :vehicles, :status, :integer
  end
end
