class MoveParkingRateToLot < ActiveRecord::Migration[5.2]
  def up
    remove_column :parking_zones, :parking_fee
    remove_column :parking_sessions, :parking_fee
    remove_column :parking_lots, :capacity
    remove_column :parking_lots, :parking_slots_count
    add_column :parking_lots, :rate, :decimal
  end

  def down
    add_column :parking_zones, :parking_fee, :decimal
    add_column :parking_sessions, :parking_fee, :decimal
    add_column :parking_lots, :capacity, :integer
    add_column :parking_lots, :parking_slots_count, :integer
    remove_column :parking_lots, :rate
  end
end
