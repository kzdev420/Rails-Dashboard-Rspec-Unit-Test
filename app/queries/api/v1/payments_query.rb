module Api
  module V1
    class PaymentsQuery < ::ApplicationQuery
      def call
        parking_lot_ids, statuses, current_user = options[:parking_lot_ids], options[:statuses], options[:current_user]

        scope = current_user.payments

        if parking_lot_ids.present?
          scope = scope.joins(:parking_session).where(parking_sessions: { parking_lot_id: parking_lot_ids })
        end

        if statuses.respond_to?(:reject)
          scope = scope.where(status: statuses.reject { |status| !::Payment.statuses.keys.include?(status.to_s) })
        end

        if options[:range].present?
          if options.dig(:range, :from).blank? && options.dig(:range, :to).present?
            to = options.dig(:range, :to).to_date
            scope = scope.where("payments.created_at <= ?", to.end_of_day)
          else
            from = options.dig(:range, :from).to_date
            to = options.dig(:range, :to).blank? ? DateTime::Infinity.new : options.dig(:range, :to).to_date.end_of_day
            scope = scope.where(created_at: from.beginning_of_day..to) if from.present? && to.present?
          end
        end

        scope.includes(parking_session: :parking_lot).order('created_at desc')
      end
    end
  end
end
