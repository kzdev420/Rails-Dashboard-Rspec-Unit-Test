module Api
  module Dashboard
    class DisputePolicy < ApplicationPolicy

      def show?
        user.admin? || record.admin_id == user.id || lot_manager?
      end

      private

      def lot_manager?
        Dispute
          .joins(parking_session: { parking_lot: :town_managers })
          .where(disputes: { id: record.id }, admins: { id: user.id })
          .exists?
      end
    end
  end
end
