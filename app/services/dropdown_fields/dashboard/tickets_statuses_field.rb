module DropdownFields
  module Dashboard
    class TicketsStatusesField < ::DropdownFields::Base

      def execute
        ::Parking::Ticket.statuses.keys.map { |key| {}.merge!(label: I18n.t("activerecord.models.tickets.statuses.#{key}"), value: key) }
      end

      def value_attr
        :value
      end

      def label_attr
        :label
      end

    end
  end
end
