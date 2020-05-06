class RemoveParkingZones < ActiveRecord::Migration[5.2]
  def up
    drop_table :parking_zones
    add_column :parking_slots, :parking_lot_id, :integer, index: true
  end

  def down
    create_table :parking_zones do |t|
      t.string :name
      t.belongs_to :parking_lot, index: true
      t.timestamps
    end
    remove_column :parking_slots, :parking_lot_id
  end
end
