class CreateParkingViolations < ActiveRecord::Migration[5.2]
  def change
    create_table :parking_violations do |t|
      t.string :description
      t.datetime :fixed_at
      t.references :rule, foreign_key: { to_table: :parking_rules }
      t.references :session, foreign_key: { to_table: :parking_sessions }

      t.timestamps
    end
  end
end
