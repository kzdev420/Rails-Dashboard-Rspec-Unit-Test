module Statistics
  class VoiMatchesCurrently < Base

    def execute
      scope = ::Parking::VehicleRule.where(created_at: Time.zone.now.utc..Time.zone.now.end_of_day.utc)

      voi_match = scope.count

      {
        title: 'VOI Matches Currently',
        disable_date_range: true,
        range_current_period: "#{Time.zone.now.strftime("%m/%d/%y")} (Today)",
        result: "#{number_with_delimiter(voi_match)} VOI",
      }
    end

  end
end
