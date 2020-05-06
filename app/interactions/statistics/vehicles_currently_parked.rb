module Statistics
  class VehiclesCurrentlyParked < Base

    def execute
      scope = ParkingSession.current.where(parking_lot_id: @parking_lots.map(&:id))

      vehicles_parked = scope.count

      {
        title: 'Vehicles Currently Parked',
        disable_date_range: true,
        range_current_period: "#{Time.zone.now.strftime("%m/%d/%y")} (Today)",
        result: "#{number_with_delimiter(vehicles_parked)} vehicles"
      }
    end

  end
end
