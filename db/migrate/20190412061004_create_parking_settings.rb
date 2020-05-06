class CreateParkingSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :parking_settings do |t|
      t.belongs_to :parking_lot, foreign_key: true
      t.float :rate
      t.integer :parked
      t.integer :overtime
      t.integer :charge

      t.timestamps
    end
  end
end
