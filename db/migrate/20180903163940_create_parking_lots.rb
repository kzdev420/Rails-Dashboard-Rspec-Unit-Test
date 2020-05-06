# frozen_string_literal: true

class CreateParkingLots < ActiveRecord::Migration[5.2]
  def change
    create_table :parking_lots do |t|
      t.string  :address
      t.integer :capacity
      t.integer :parking_slots_count, default: 0
      t.timestamps
    end
  end
end
