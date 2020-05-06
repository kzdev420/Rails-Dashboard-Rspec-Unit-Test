module DropdownFields
  module Dashboard
    class RoleNamesFilter < ::DropdownFields::Base

      def execute
        Role.all.reject { |role| role == Role.find_by(name: 'super_admin') }
      end

      def value_attr
        :name
      end

      def label_attr
        :name
      end

    end
  end
end
