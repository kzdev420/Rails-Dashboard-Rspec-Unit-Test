module Api
  module V1
      class PaymentSerializer < ::ApplicationSerializer
        attributes :amount,
          :status,
          :created_at,
          :parking_session_id,
          :parking_lot

        def parking_lot
          Api::V1::Parking::ThinLotSerializer.new(object.parking_session.parking_lot)
        end

      end
  end
end