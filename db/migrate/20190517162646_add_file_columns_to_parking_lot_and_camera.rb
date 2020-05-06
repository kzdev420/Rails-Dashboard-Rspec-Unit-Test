class AddFileColumnsToParkingLotAndCamera < ActiveRecord::Migration[5.2]
  def change
    add_column :parking_lots, :outline, :json
    add_column :cameras, :vmarkup, :json
  end
end
