class AddArchivedColumnToParkingSlot < ActiveRecord::Migration[5.2]
  def change
    add_column :parking_slots, :archived, :boolean, default: false
  end
end
