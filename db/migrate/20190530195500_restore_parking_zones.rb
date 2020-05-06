class RestoreParkingZones < ActiveRecord::Migration[5.2]
  def change
    create_table :parking_zones do |t|
      t.string :name
      t.references :lot, index: true, foreign_key: { to_table: :parking_lots }
      t.timestamps
    end
  end
end
