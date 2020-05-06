class CreateAiLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :ai_logs do |t|
      t.integer :status, default: 0
      t.text :payload
      t.text :message

      t.timestamps
    end
  end
end
