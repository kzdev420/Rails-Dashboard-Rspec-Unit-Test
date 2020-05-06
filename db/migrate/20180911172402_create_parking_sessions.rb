# frozen_string_literal: true

class CreateParkingSessions < ActiveRecord::Migration[5.2]
  def change
    create_table :parking_sessions do |t|
      t.datetime :check_in
      t.datetime :check_out
      t.decimal  :parking_fee
      t.references :parking_slot
      t.references :vehicle
      t.timestamps
    end
  end
end
