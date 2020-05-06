class AddParkedAtToParkingSession < ActiveRecord::Migration[5.2]
  def change
    add_column :parking_sessions, :parked_at, :datetime
    add_column :parking_sessions, :left_at, :datetime
  end
end
