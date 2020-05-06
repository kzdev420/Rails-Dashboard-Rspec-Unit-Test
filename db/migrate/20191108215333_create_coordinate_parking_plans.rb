class CreateCoordinateParkingPlans < ActiveRecord::Migration[5.2]
  def change
    create_table :coordinate_parking_plans do |t|
      t.float :x
      t.float :y
      t.references :parking_slot, foreign_key: true
      t.references :image, foreign_key: true

      t.timestamps
    end
  end
end
