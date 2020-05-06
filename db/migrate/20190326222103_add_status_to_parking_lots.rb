class AddStatusToParkingLots < ActiveRecord::Migration[5.2]
  def change
    add_column :parking_lots, :avatar, :string
    add_column :parking_lots, :status, :integer, default: 0
  end
end
