module Api
  module Dashboard
    module Parking
      class SessionSerializer < ::ParkingSessionSerializer
        include ActionView::Helpers::NumberHelper

        attributes :id,
          :check_in,
          :check_out,
          :created_at,
          :paid,
          :total_price,
          :fee_applied,
          :user_id,
          :kiosk_id,
          :payments,
          :slot

        N_A = 'N/A'.freeze

        belongs_to :vehicle, serializer: ThinVehicleSerializer

        def user_id
          object.vehicle.user.present? ? object.vehicle.user.id : "NOT ACCOUNT"
        end

        def slot
          if object.parking_slot.present?
            {
              id: object.parking_slot.id,
              name: object.parking_slot.name
            }
          end
        end

        def total_price
          object.fee_applied.present? ? number_to_currency(payment_info.pay / 100.to_f) : N_A
        end

        def status
          object.created? ? 'In Progress' : object.status
        end

        def paid
          if object.fee_applied.present?
            object.paid? ? 'PAID' : "UNPAID"
          else
             N_A
          end
        end

        def fee_applied
          object.fee_applied.present? ? number_to_currency(object.fee_applied) : N_A
        end

      end
    end
  end
end