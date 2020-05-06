module DropdownFields
  module Dashboard
    class RoleId < ::DropdownFields::Base

      def execute
        user = Admin.find(params[:admin_id])
        if params[:edited_admin_id]
          edited_user = Admin.find(params[:edited_admin_id])
          return user.role.all_allowed_to(:create).reject { |role| role == Role.find_by(name: 'system_admin') && edited_user.role.name != 'system_admin' }
        end
        user.role.all_allowed_to(:create).reject { |role| role == Role.find_by(name: 'system_admin') }
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
