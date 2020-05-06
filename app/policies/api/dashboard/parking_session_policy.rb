module Api
  module Dashboard
    class ParkingSessionPolicy < ::ApplicationPolicy

      def show?
        user.admin? || record.parking_lot.parking_admin&.id == user.id || record.parking_lot.town_manager&.id == user.id
      end

    end
  end
end
