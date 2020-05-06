class RemovePainColumnFromParkingSessions < ActiveRecord::Migration[5.2]
  def change
    remove_column :parking_sessions, :paid, :boolean
  end
end
