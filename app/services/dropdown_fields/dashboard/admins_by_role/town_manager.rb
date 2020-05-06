module DropdownFields
  module Dashboard
    module AdminsByRole
      class TownManager < ::DropdownFields::Base

        def execute
          Admin.joins(:role).where(status: :active, roles: { name: 'town_manager' }).select('admins.*, roles.name')
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
end
