class AddParkingLotIdToParkingSessions < ActiveRecord::Migration[5.2]
  def change
    add_column :parking_sessions, :parking_lot_id, :integer, index: true
  end
end
