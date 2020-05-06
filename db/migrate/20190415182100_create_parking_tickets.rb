class CreateParkingTickets < ActiveRecord::Migration[5.2]
  def change
    create_table :parking_tickets do |t|
      t.references :subject, polymorphic: true
      t.references :admin, foreign_key: true
      t.references :agency, foreign_key: true
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
