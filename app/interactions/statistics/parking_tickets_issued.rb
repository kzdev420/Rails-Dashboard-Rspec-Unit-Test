module Statistics
  class ParkingTicketsIssued < Base

    def execute
      Rails.cache.fetch("statistics/parking_tickets_issued/#{@from.strftime("%m-%d-%y")}_#{@to.strftime("%m-%d-%y")}", expires_in: 20.minutes) do
        previous_scope = ::Parking::Ticket.where(created_at: @previous_from.utc..@previous_to.utc, status: :issued)
        scope = ::Parking::Ticket.where(created_at: @from.utc..@to.utc, status: :issued)
        previous_count = previous_scope.count > 0 ? previous_scope.count : 1
        percentage = (((scope.count-previous_scope.count)*100)/previous_count.to_f)
        ticket_issued_count = scope.count

        {
          title: 'Parking Tickets Issued',
          range_current_period: range_current_period,
          result: "#{number_with_delimiter(ticket_issued_count)} tickets",
          compare_with_previous_period: {
            raise: percentage > 0,
            percentage: "#{number_with_delimiter(sprintf "%.2f", percentage.abs)}%"
          },
          result_previous_period: result_previous_period(number_with_delimiter(previous_scope.count), 'tickets')
        }
      end
    end

  end
end
