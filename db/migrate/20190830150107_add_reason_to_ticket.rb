class AddReasonToTicket < ActiveRecord::Migration[5.2]
  def change
    add_column :parking_tickets, :reason, :text
    add_column :parking_tickets, :photo_resolution, :string
  end
end
