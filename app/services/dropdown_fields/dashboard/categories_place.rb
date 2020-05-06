module DropdownFields
  module Dashboard
    class CategoriesPlace < ::DropdownFields::Base

      def execute
        Place.categories.keys.map { |key| { name: key } }
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
