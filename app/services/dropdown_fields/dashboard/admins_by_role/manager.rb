module DropdownFields
  module Dashboard
    module AdminsByRole
      class Manager < ::DropdownFields::Base

        def execute
          Admin.joins(:role).where(status: :active, roles: { name: 'manager' }).select('admins.*, roles.name')
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
