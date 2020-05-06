class CreateParkingTicketLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :parking_ticket_logs do |t|
      t.references :ticket, foreign_key: { to_table: :parking_tickets }
      t.integer :template, default: 0
      t.string :text

      t.timestamps
    end
  end
end
