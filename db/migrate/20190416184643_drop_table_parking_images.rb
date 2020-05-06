class DropTableParkingImages < ActiveRecord::Migration[5.2]
  def change
    drop_table :parking_images do |t|
      t.string :file
      t.references :parking_session
      t.timestamps
    end
  end
end
