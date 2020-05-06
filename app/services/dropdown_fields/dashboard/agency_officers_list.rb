module DropdownFields
  module Dashboard
    class AgencyOfficersList < ::DropdownFields::Base

      def execute
        agency = Agency.find_by(id: params[:agency_id])
        unassigned_option + (agency&.officers || [] )
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
