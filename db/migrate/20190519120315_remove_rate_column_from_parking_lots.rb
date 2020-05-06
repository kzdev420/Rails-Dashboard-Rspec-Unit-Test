class RemoveRateColumnFromParkingLots < ActiveRecord::Migration[5.2]
  def change
    remove_column :parking_lots, :rate, :decimal
  end
end
