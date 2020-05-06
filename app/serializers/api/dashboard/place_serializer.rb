module Api
  module Dashboard
    class PlaceSerializer < ::ApplicationSerializer
      attributes :id, :name, :category, :distance

      def name
        object.name.strip
      end

    end
  end
end