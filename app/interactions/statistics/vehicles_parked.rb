module Statistics
  class VehiclesParked < Base

    def execute
      Rails.cache.fetch("statistics/vehicles_parked/#{@from.strftime("%m-%d-%y")}_#{@to.strftime("%m-%d-%y")}", expires_in: 20.minutes) do
        scope = ParkingSession.where.not(parked_at: nil).where(parking_lot_id: @parking_lots.map(&:id))

        previous_scope = scope.where(parked_at: @previous_from.utc..@previous_to.utc)
        scope = scope.where(parked_at: @from.utc..@to.utc)

        previous_count = previous_scope.count > 0 ? previous_scope.count : 1
        percentage = (((scope.count-previous_scope.count)*100)/previous_count.to_f)
        vehicles_parked = scope.count

        {
          title: 'Vehicles Parked',
          range_current_period: range_current_period,
          result: "#{number_with_delimiter(vehicles_parked)} vehicles",
          compare_with_previous_period: {
            raise: percentage > 0,
            percentage: "#{number_with_delimiter(sprintf "%.2f", percentage.abs)}%"
          },
          result_previous_period: result_previous_period(number_with_delimiter(previous_scope.count), 'vehicles')
        }
      end
    end

  end
end
