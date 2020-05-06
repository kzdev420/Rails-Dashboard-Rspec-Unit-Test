class DeleteAdminParkingLots < ActiveRecord::Migration[5.2]
  def up
    drop_table :admins_parking_lots
  end

  def down
    create_table :admins_parking_lots, id: false do |t|
      t.integer :admin_id, index: true
      t.integer :parking_lot_id, index: true
    end
  end
end
