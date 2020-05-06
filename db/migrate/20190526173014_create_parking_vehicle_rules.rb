class CreateParkingVehicleRules < ActiveRecord::Migration[5.2]
  def change
    create_table :parking_vehicle_rules do |t|
      t.string :color
      t.references :vehicle, foreign_key: true
      t.string :vehicle_type
      t.integer :status, default: 0
      t.references :lot, foreign_key: { to_table: :parking_lots }

      t.timestamps
    end
  end
end
