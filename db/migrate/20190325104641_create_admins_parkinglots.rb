class CreateAdminsParkinglots < ActiveRecord::Migration[5.2]
  def change
    create_table :admins_parking_lots, id: false do |t|
      t.integer :admin_id, index: true
      t.integer :parking_lot_id, index: true
    end
  end
end
