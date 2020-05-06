class RenameParkingLotReferenceOnParkingSettings < ActiveRecord::Migration[5.2]
  def change
    rename_column :parking_settings, :parking_lot_id, :lot_id
  end
end
