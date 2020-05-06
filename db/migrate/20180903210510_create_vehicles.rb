# frozen_string_literal: true

class CreateVehicles < ActiveRecord::Migration[5.2]
  def change
    create_table :vehicles do |t|
      t.string :plate_number
      t.string :vehicle_type
      t.string :color
      t.string :model

      t.timestamps
    end
  end
end
