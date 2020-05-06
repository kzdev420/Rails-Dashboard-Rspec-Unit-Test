class DropParkingTicketLog < ActiveRecord::Migration[5.2]
  def change
    drop_table :parking_ticket_logs
  end
end
