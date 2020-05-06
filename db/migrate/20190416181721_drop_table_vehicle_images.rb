class DropTableVehicleImages < ActiveRecord::Migration[5.2]
  def change
    drop_table :vehicle_images do |t|
      t.string :file
      t.references :vehicle
      t.timestamps
    end
  end
end
