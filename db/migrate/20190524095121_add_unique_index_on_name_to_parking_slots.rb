class AddUniqueIndexOnNameToParkingSlots < ActiveRecord::Migration[5.2]
  def change
    add_index :parking_slots, [:name, :parking_lot_id], unique: true
  end
end
