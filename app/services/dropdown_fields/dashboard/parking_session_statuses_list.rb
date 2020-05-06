module DropdownFields
  module Dashboard
    class ParkingSessionStatusesList < ::DropdownFields::Base

      def execute
        ParkingSession.statuses.map do |status|
          {
            label: status.first,
            value: status.last
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
