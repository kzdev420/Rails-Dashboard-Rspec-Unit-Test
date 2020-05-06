module Api
  module Dashboard
    class DisputesIndexQuery < ApplicationQuery
      def call
        user = options[:user]
        scope = Dispute.with_role_condition(user)

        if options[:status].present?
          scope = scope.where(disputes: { status: options[:status] })
        end

        if options[:parking_lot_id].present?
          scope = scope.joins(:parking_session).where(parking_sessions: { parking_lot_id: options[:parking_lot_id] })
        end

        if (user.system_admin? || user.super_admin?) && options[:admin_id].present?
          scope = scope.where(admin_id: options[:admin_id])
        end

        scope.includes(:user, :admin, parking_session: :vehicle)
      end
    end
  end
end
