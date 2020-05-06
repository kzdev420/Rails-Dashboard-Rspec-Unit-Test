module DropdownFields
  module Mobile
    class ManufacturersList < ::DropdownFields::Base

      def execute
        Manufacturer.all.order("name = 'others' desc, name asc").map do |manufacturer|
          ::ManufacturerSerializer.new(manufacturer).to_h
        end
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
