module DropdownFields
  module Dashboard
    class TicketsOfficersFilter < ::DropdownFields::Base

      def execute
        admin = Admin.find_by(id: params[:admin_id])
        list = ::Parking::Ticket.with_role_condition(admin).includes(:admin).select(:admin_id).distinct.map(&:admin).compact
        unassigned_option + list
      end

      def value_attr
        :id
      end

      def label_attr
        :email
      end

      def unassigned_option
        [{ id: 0, email: 'Unassigned' }]
      end
    end
  end
end
