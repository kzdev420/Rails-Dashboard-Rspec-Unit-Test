class AddTimeZoneToParkingLot < ActiveRecord::Migration[5.2]
  def change
    add_column :parking_lots, :time_zone, :string, default: 'Eastern Time (US & Canada)'
  end
end
