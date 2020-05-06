class RemoveVehicleIdFromParkingSlots < ActiveRecord::Migration[5.2]
  def up
    remove_column :parking_slots, :vehicle_id
  end

  def down
    add_column :parking_slots, :vehicle_id, :integer, index: true
  end
end
