class AddColumnKioskToParkingSession < ActiveRecord::Migration[5.2]
  def change
    add_reference :parking_sessions, :kiosk, foreign_key: true
  end
end
