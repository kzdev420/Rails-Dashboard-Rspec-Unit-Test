class AddEmailToParkingLots < ActiveRecord::Migration[5.2]
  def change
    add_column :parking_lots, :email, :string
  end
end
