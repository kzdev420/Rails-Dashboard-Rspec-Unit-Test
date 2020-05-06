class DropPakringLogs < ActiveRecord::Migration[5.2]
  def change
    drop_table :parking_logs
  end
end
