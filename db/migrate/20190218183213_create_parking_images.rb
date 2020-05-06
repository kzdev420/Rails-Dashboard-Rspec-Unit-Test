class CreateParkingImages < ActiveRecord::Migration[5.2]
  def change
    create_table :parking_images do |t|
      t.string :file
      t.references :parking_session
      t.timestamps
    end
  end
end
