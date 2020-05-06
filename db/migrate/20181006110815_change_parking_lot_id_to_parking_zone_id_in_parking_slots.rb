class ChangeParkingLotIdToParkingZoneIdInParkingSlots < ActiveRecord::Migration[5.2]
  def change
    change_table :parking_slots do |t|
      t.remove :parking_lot_id
      t.references :parking_zone
    end
  end
end
