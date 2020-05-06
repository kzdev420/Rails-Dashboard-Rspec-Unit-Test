class CreateParkingRules < ActiveRecord::Migration[5.2]
  def change
    create_table :parking_rules do |t|
      t.integer :name, default: 0
      t.text :description
      t.boolean :status, default: false
      t.references :agency, foreign_key: true
      t.references :parking_lot, foreign_key: true

      t.timestamps
    end
  end
end
