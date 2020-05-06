class AddNameLngLtfToParkingLots < ActiveRecord::Migration[5.2]
  def change
    add_column :parking_lots, :ltd, :decimal
    add_column :parking_lots, :lng, :decimal
    add_column :parking_lots, :name, :string
    add_column :parking_lots, :phone, :string
  end
end
