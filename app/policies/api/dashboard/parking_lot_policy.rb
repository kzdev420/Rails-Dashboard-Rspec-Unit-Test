module Api
  module Dashboard
    class ParkingLotPolicy < ::ApplicationPolicy

      # Parking Rule Policy 'create' should be the same
      def create?
        user.admin?
      end

      def update?
        user.admin? || record.parking_admin&.id == user.id || record.town_manager&.id == user.id
      end

      def show?
        user.admin? || record.parking_admin&.id == user.id || record.town_manager&.id == user.id
      end
    end
  end
end
