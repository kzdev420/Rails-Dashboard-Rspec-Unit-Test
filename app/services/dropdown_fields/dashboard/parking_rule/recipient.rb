module DropdownFields
  module Dashboard
    module ParkingRule
      class Recipient < ::DropdownFields::Base

        def execute
          Admin.where("email ilike ?", "%#{params[:email]}%").where(status: :active).limit(10).map  do |admin|
            { id: admin.id, data: admin.attributes.merge(role: { name: admin.role.name }) }
          end
        end

        def value_attr
          :id
        end

        def label_attr
          :data
        end

      end
    end
  end
end
