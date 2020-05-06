class AddStatusToParkingSlots < ActiveRecord::Migration[5.2]
  def change
    add_column :parking_slots, :status, :integer, default: 0
  end
end
