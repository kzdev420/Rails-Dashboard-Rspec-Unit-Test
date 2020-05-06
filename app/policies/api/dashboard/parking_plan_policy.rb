module Api
  module Dashboard
    class ParkingPlanPolicy < ::ApplicationPolicy

      def create?
        user.admin? || record.parking_admin&.id == user.id || record.town_manager&.id == user.id
      end

      def update?
        user.admin? || record.parking_admin&.id == user.id || record.town_manager&.id == user.id
      end

      def destroy?
        user.admin? || record.parking_admin&.id == user.id || record.town_manager&.id == user.id
      end

    end
  end
end
