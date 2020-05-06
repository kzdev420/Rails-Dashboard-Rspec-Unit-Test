class CreateParkingLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :parking_logs do |t|
      t.integer :name, default: 0
      t.string :text
      t.references :session, foreign_key: { to_table: :parking_sessions }

      t.timestamps
    end
  end
end
