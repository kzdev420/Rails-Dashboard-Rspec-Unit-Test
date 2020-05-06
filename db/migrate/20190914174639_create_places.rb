class CreatePlaces < ActiveRecord::Migration[5.2]
  def change
    create_table :places do |t|
      t.references :parking_lot, foreign_key: true
      t.string :name
      t.integer :category
      t.float :distance

      t.timestamps
    end
  end
end
