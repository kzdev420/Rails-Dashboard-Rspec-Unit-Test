module DropdownFields
  module Dashboard
    class TicketsAgenciesList < ::DropdownFields::Base

      def execute
        admin = Admin.find_by(id: params[:admin_id])
        ::Parking::Ticket.with_role_condition(admin).includes(:agency).select(:agency_id).distinct.map(&:agency).compact
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
