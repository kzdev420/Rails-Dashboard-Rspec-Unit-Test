class AddUuidToParkingSessions < ActiveRecord::Migration[5.2]
  def change
    add_column :parking_sessions, :uuid, :string, index: true
  end
end
