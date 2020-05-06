class AddEnteredAtAndExitAtColumnsToParkingSession < ActiveRecord::Migration[5.2]
  def change
    add_column :parking_sessions, :entered_at, :datetime
    add_column :parking_sessions, :exit_at, :datetime
    add_column :parking_sessions, :ai_status, :integer, default: 0
  end
end
