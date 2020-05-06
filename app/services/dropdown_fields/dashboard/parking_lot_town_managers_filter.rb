module DropdownFields
  module Dashboard
    class ParkingLotTownManagersFilter < ::DropdownFields::Base

      def execute
        user = Admin.find(params[:admin_id])
        parking_lots = user.available_parking_lots.order(id: :desc)

        parking_lots.flat_map do |parking_lot|
          parking_lot.town_managers.select(:id, :email)
        end.uniq
      end

      def value_attr
        :id
      end

      def label_attr
        :email
      end

    end
  end
end
