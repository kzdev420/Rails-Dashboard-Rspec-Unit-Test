module Statistics
  class Revenue < Base

    def execute
      Rails.cache.fetch("statistics/revenue/#{@from.strftime("%m-%d-%y")}_#{@to.strftime("%m-%d-%y")}", expires_in: 20.minutes) do
        previous_amount = Payment.success.where(created_at: @previous_from.utc..@previous_to.utc).sum(:amount)
        current_amount = Payment.success.where(created_at: @from.utc..@to.utc).sum(:amount)

        previous_amount = previous_amount > 0 ? previous_amount : 1
        percentage = (((current_amount-previous_amount)*100)/previous_amount.to_f)

        {
          title: 'Revenue',
          range_current_period: range_current_period,
          result: "$#{number_with_delimiter(current_amount.to_i)}",
          compare_with_previous_period: {
            raise: percentage > 0,
            percentage: "#{number_with_delimiter(sprintf "%.2f", percentage.abs)}%"
          },
          result_previous_period: result_previous_period("$#{number_with_delimiter(previous_amount.to_i)}", '')
        }
      end
    end

  end
end
