module DropdownFields
  module Dashboard
    class TicketsTypesField < ::DropdownFields::Base

      def execute
        ::Parking::Rule.names.keys.map { |key| {}.merge!(name: key) }
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
