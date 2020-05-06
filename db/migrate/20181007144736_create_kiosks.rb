# frozen_string_literal: true

class CreateKiosks < ActiveRecord::Migration[5.2]
  def change
    create_table :kiosks do |t|
      t.belongs_to :parking_lot
      t.timestamps
    end
  end
end
