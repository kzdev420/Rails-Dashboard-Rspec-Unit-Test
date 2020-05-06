class DropAiLogs < ActiveRecord::Migration[5.2]
  def change
    drop_table :ai_logs
  end
end
