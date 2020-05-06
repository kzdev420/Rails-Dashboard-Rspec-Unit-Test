# frozen_string_literal: true

class CreateParkingZones < ActiveRecord::Migration[5.2]
  def change
    create_table :parking_zones do |t|
      t.string :name
      t.decimal :parking_fee
      t.belongs_to :parking_lot, index: true
      t.timestamps
    end
  end
end
