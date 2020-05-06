class AddStatusToParkingSessions < ActiveRecord::Migration[5.2]
  def change
    add_column :parking_sessions, :status, :integer, default: 0
    add_column :parking_sessions, :paid, :boolean, default: false
  end
end
