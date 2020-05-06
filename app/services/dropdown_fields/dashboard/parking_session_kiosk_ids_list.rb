module DropdownFields
  module Dashboard
    class ParkingSessionKioskIdsList < ::DropdownFields::Base

      def execute
        parking_lot = ParkingLot.find_by(id: params[:parking_lot_id])
        parking_lot.parking_sessions.pluck(:kiosk_id).compact.uniq.map do |kiosk_id|
          {
            label: kiosk_id,
            value: kiosk_id
          }
        end
      end

      def value_attr
        :value
      end

      def label_attr
        :label
      end

    end
  end
end
