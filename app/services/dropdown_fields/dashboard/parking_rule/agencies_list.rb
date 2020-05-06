module DropdownFields
  module Dashboard
    module ParkingRule
      class AgenciesList < ::DropdownFields::Base

        def execute
          admin = Admin.find_by(id: params[:admin_id])
          scope = Agency.with_role_condition(admin).to_a
          if params[:parking_lot_id].present?
            parking_lot = ParkingLot.find_by(id: params[:parking_lot_id])
            agencies_parking_rule = parking_lot.rules.map(&:agency_id).compact # TODO: Add delete repeted ID
            scope_agency_ids = scope.map(&:id)
            # Show current agency rule even if the user doesn't have access to read it
            agencies_parking_rule.each do |agency_id|
              scope.push(Agency.find_by(id: agency_id)) unless scope_agency_ids.include?(agency_id)
            end
          end
          scope
        end

        def value_attr
          :id
        end

        def label_attr
          :name
        end

      end
    end
  end
end
