module Api
  module Dashboard
    class DetailedParkingLotSerializer < Api::Dashboard::Parking::LotSerializer
      attributes :avatar, :status

      def avatar
        url_for(object.avatar) if object.avatar.attached?
      end
    end
  end
end
