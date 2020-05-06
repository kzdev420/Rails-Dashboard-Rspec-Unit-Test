module Api
  module Dashboard
    class ParkingSessionQuery < ::ApplicationQuery

      def call
        parking_lot_id, query, parking_session_id, order = options[:parking_lot_id], options[:query], options[:parking_session_id], options[:order]
        query, payment_methods, statuses, user_ids =  options[:query], options[:payment_methods], options[:statuses], options[:user_ids]
        kiosk_ids, slot_name, fee_applied, total_price = options[:kiosk_ids], options[:slot_name], options[:fee_applied], options[:total_price]

        return ParkingSession.none unless parking_lot_id.present?

        scope = ParkingSession.joins(:vehicle, :parking_slot).where(parking_lot_id: parking_lot_id)

        return ParkingSession.where(id: parking_session_id) if parking_session_id.present?

        scope = scope.joins(:payments).where("payments.payment_method IN (?)", payment_methods ) if payment_methods.present?

        scope = scope.where(status: statuses ) if statuses.present?

        scope = scope.joins(:user).where(users: { id: user_ids } ) if user_ids.present?

        scope = scope.where(kiosk_id: kiosk_ids) if kiosk_ids.present?

        scope = scope.where(parking_slots: { name: slot_name } ) if slot_name.present?

        scope = scope.where(fee_applied: fee_applied.to_f ) if fee_applied.present?

        if options[:created_at].present?
          from = options.dig(:created_at, :from).to_date
          to = options.dig(:created_at, :to).blank? ? DateTime::Infinity.new : options.dig(:created_at, :to).to_date.end_of_day
          scope = scope.where(created_at: from.beginning_of_day..to)
        end

        if options[:check_in].present?
          from = options.dig(:check_in, :from).to_date
          to = options.dig(:check_in, :to).blank? ? DateTime::Infinity.new : options.dig(:check_in, :to).to_date.end_of_day
          scope = scope.where(check_in: from.beginning_of_day..to)
        end

        if options[:check_out].present?
          from = options.dig(:check_out, :from).to_date
          to = options.dig(:check_out, :to).blank? ? DateTime::Infinity.new : options.dig(:check_out, :to).to_date.end_of_day
          scope = scope.where(check_out: from.beginning_of_day..to)
        end

        if query.present?
          sql_query = []
          attr_query = []

          %w(vehicles).each do |model_name|
            if query[model_name.to_sym].present?
              query[model_name.to_sym].each do |attr, value|
                sql_query.push("#{model_name}.#{attr} ilike ?")
                attr_query.push("%#{value}%")
              end
            end
          end
          scope = scope.where(sql_query.join(' AND '), *attr_query)
        end

        if order.present?
          keyword, direction = options[:order][:keyword], options[:order][:direction]
          scope = scope.order(Arel.sql("#{keyword} #{direction}"))
          scope = order_by_slot_name(scope, direction) if keyword.include?("parking_slot")
        else
          scope = scope.order("parking_sessions.created_at DESC")
        end

        scope = scope.select { |session|  (session.payment_info.pay/100) == total_price.to_f } if total_price.present?

        scope
      end

      private

      # Slot name could be either number or strings
      def order_by_slot_name(scope, direction)
        scope = scope.sort_by do |session|
          slot_name = session.parking_slot&.name
          slot_name ||= direction == "asc" ? '0' : 'ZZ' # Make empty spaces be always last
          slot_name.split(/(\d+)/). # split numeric parts from non-numeric
            map do |slot_name| # the below parses numeric parts as decimals, ignores the rest
              begin Integer(slot_name, 10);
              rescue ArgumentError;
                slot_name
              end
            end
        end
        scope = scope.reverse! if direction == "asc"
        scope
      end

    end
  end
end
