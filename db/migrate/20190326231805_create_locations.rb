class CreateLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :locations do |t|
      t.string :zip
      t.string :building
      t.string :street
      t.string :city
      t.string :country
      t.float :ltd
      t.float :lng
      t.references :parking_lot, index: true
      t.timestamps
    end
  end
end
