module Api
  module Dashboard
    class TicketsIndexQuery < ::ApplicationQuery
      def call
        scope = ::Parking::Ticket.with_role_condition(options[:user])

        if options[:type].present?
          scope = scope
            .joins(violation: :rule)
            .where(::Parking::Rule.arel_table[:name].eq(::Parking::Rule.names[options[:type]]))
        end

        if options[:query].present?
          scope = scope
            .joins(violation: { rule: :lot })
            .where(ParkingLot.arel_table[:name].matches("%#{options[:query]}%"))
        end

        if options[:range].present?
          from = options.dig(:range, :from).to_date
          to = options.dig(:range, :to).blank? ? DateTime::Infinity.new : options.dig(:range, :to).to_date.end_of_day
          scope = scope.where(created_at: from.beginning_of_day..to) if from.present? && to.present?
        end

        if options[:agency_ids].present?
          scope = scope.where(agency_id: options[:agency_ids])
        end

        if options[:admin_ids].present?
          scope = scope.where(admin_id: options[:admin_ids])
        end

        if options[:ticket_id].present?
          scope = scope.where(id: options[:ticket_id])
        end

        if options[:parking_lot_id].present?
          scope = scope
            .joins(violation: { rule: :lot })
            .where(ParkingLot.arel_table[:id].eq(options[:parking_lot_id]))
        end

        if options[:status].present?
          scope = scope.where(status: options[:status])
        end

        if options[:order].present?
          keyword, direction = options[:order][:keyword], options[:order][:direction]
          scope = scope.joins(:admin, violation: { rule: :lot }).order(Arel.sql("#{keyword} #{direction}"))
        else
          scope = scope.order(id: :desc)
        end

        scope.includes(:admin, :agency, violation: { rule: :lot })
      end
    end
  end
end
