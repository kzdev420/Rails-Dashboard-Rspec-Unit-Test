# frozen_string_literal: true

class CreateParkingSlots < ActiveRecord::Migration[5.2]
  def change
    create_table :parking_slots do |t|
      t.string :name
      t.string  :category
      t.references :parking_lot
      t.references :vehicle
      t.timestamps
    end

  end
end
