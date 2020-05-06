class DeleteReasonFromParkingTickets < ActiveRecord::Migration[5.2]
  def change
    remove_column :parking_tickets, :reason
  end
end
