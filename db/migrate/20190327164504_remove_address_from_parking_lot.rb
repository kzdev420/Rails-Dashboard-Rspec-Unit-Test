class RemoveAddressFromParkingLot < ActiveRecord::Migration[5.2]
  def up
    remove_column :parking_lots, :lng
    remove_column :parking_lots, :ltd
    remove_column :parking_lots, :address
  end

  def down
    add_column :parking_lots, :lng, :decimal
    add_column :parking_lots, :ltd, :decimal
    add_column :parking_lots, :address, :string
  end
end
