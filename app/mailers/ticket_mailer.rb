class TicketMailer < ApplicationMailer
  def ticket_changed(ticket_id, change, from, to)
    @ticket = Parking::Ticket.find(ticket_id)
    @admin = Admin.find(@ticket.admin_id)
    @change = change
    @from = from
    @to = to

    mail to: @admin.email
  end
end
