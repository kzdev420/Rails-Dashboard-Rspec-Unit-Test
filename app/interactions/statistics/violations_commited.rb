module Statistics
  class ViolationsCommited < Base

    def execute
      Rails.cache.fetch("statistics/violation_commited/#{@from.strftime("%m-%d-%y")}_#{@to.strftime("%m-%d-%y")}", expires_in: 20.minutes) do
        previous_scope = ::Parking::Violation.where(created_at: @previous_from.utc..@previous_to.utc)
        scope = ::Parking::Violation.where(created_at: @from.utc..@to.utc)

        previous_count = previous_scope.count > 0 ? previous_scope.count : 1
        percentage = (((scope.count-previous_scope.count)*100)/previous_count.to_f)
        violation_commited_count = scope.count

        {
          title: 'Violations Commited',
          range_current_period: range_current_period,
          result: "#{number_with_delimiter(violation_commited_count)} violations",
          compare_with_previous_period: {
            raise: percentage > 0,
            percentage: "#{number_with_delimiter(sprintf "%.2f", percentage.abs)}%"
          },
          result_previous_period: result_previous_period(number_with_delimiter(previous_scope.count), 'violations')
        }
      end
    end

  end
end
