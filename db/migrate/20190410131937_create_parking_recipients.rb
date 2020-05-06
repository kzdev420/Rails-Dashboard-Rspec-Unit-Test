class CreateParkingRecipients < ActiveRecord::Migration[5.2]
  def change
    create_table :parking_recipients do |t|
      t.belongs_to :rule, foreign_key: { to_table: :parking_rules }
      t.belongs_to :admin, foreign_key: true

      t.timestamps
    end
  end
end
