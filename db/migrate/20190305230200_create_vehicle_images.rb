class CreateVehicleImages < ActiveRecord::Migration[5.2]
  def change
    create_table :vehicle_images do |t|
      t.string :file
      t.references :vehicle
      t.timestamps
    end
  end
end
