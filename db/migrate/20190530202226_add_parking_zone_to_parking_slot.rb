class AddParkingZoneToParkingSlot < ActiveRecord::Migration[5.2]
  def change
    add_reference :parking_slots, :zone, foreign_key: { to_table: :parking_zones }
  end
end
