class DeleteCategoryFromParkingSlot < ActiveRecord::Migration[5.2]
  def change
    remove_column :parking_slots, :category
  end
end
