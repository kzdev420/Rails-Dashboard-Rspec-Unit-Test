class AddFreeTimeToParkingSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :parking_settings, :free, :integer, default: 0
  end
end
