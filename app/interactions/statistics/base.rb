module Statistics
  class Base < ::ApplicationInteraction
    include ActionView::Helpers::NumberHelper

    object :current_user, class: Admin
    array :parking_lot_ids, default: [] do
      integer
    end
    hash :range, strip: false, default: nil

    set_callback :execute, :before, -> do
      set_parking_lots
      set_date_variables
    end

    def set_parking_lots
      lots = current_user.available_parking_lots
      @parking_lots = parking_lot_ids.present? ? lots.where(id: parking_lot_ids) : lots
    end

    def set_date_variables
      Time.zone = current_time_zone

      if range.present?
        from = Time.zone.parse(range[:from])
        to = range[:to].blank? ? from.end_of_day : Time.zone.parse(range[:to]).end_of_day
      else
        from = Time.zone.now.beginning_of_week
        to = Time.zone.now.end_of_week
      end

      if from.to_date == from.to_date.at_beginning_of_month && to.to_date == to.to_date.at_end_of_month # Monthly
        previous_from = from.at_beginning_of_month - 1.month
        previous_to = (from.at_beginning_of_month - 1.month).at_end_of_month
      else
        previous_date = (to.to_date-from.to_date).to_i + 1
        previous_from = from - previous_date.days
        previous_to = to - previous_date.days
      end

      @from = from
      @to = to
      @previous_from = previous_from
      @previous_to = previous_to
    end

    def current_time_zone
      return @time_zone if @time_zone.present?
      @time_zone = @parking_lots.uniq { |p| p.time_zone }.count == 1 ? @parking_lots.first.time_zone : 'UTC'
    end

    def range_current_period
      return "#{@from.strftime("%m/%d/%y")}-#{@to.strftime("%m/%d/%y")}" if @from.to_date != @to.to_date
      return "#{@from.strftime("%m/%d/%y")}"
    end

    def result_previous_period(count, name)
      return "#{count} #{name} - #{@previous_from.strftime("%m/%d/%y")}-#{@previous_to.strftime("%m/%d/%y")}" if @previous_from.to_date != @previous_to.to_date
      return "#{count} #{name} - #{@previous_from.strftime("%m/%d/%y")}"
    end
  end
end
