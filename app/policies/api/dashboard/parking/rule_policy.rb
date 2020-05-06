module Api
  module Dashboard
    class Parking::RulePolicy < ::ApplicationPolicy
      # Parking Lot Policy 'create' should be the same
      def create?
        user.admin?
      end

      def update?
        user.admin? || record.lot.parking_admin&.id == user.id || record.lot.town_manager&.id == user.id
      end
    end
  end
end
