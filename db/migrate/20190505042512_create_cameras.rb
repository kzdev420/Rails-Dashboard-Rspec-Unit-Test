class CreateCameras < ActiveRecord::Migration[5.2]
  def change
    create_table :cameras do |t|
      t.string :stream
      t.string :login
      t.string :name
      t.string :password
      t.references :parking_lot, foreign_key: true

      t.timestamps
    end
  end
end
