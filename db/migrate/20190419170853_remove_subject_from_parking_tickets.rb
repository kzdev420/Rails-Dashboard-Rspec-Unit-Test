class RemoveSubjectFromParkingTickets < ActiveRecord::Migration[5.2]
  def change
    remove_reference :parking_tickets, :subject, polymorphic: true
    add_reference :parking_tickets, :violation, foreign_key: { to_table: :parking_violations }
  end
end
