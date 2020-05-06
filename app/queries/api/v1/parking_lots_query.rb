module Api
  module V1
    class ParkingLotsQuery < ::ApplicationQuery
      def initialize(options = {})
        @query = options[:query]
        location_radius = options[:location_radius] || {}
        @ltd = location_radius[:ltd]
        @lng = location_radius[:lng]
        @distance = location_radius[:distance]
        super
      end

      def call
        scope = ParkingLot
          .includes(:location, :setting)
          .joins(:location)
          .active
          .order(:name)

        scope = scope.where("
          earth_box(ll_to_earth(?, ?), #{@distance || 10}*1000)
          @> ll_to_earth(locations.ltd, locations.lng)",
          @ltd, @lng) if @ltd.present? && @lng.present?

        return scope if @query.blank?

        scope
          .where(build_condition)
      end

      private

      def like(column)
        column.matches("%#{@query}%")
      end

      def build_condition
        parking_lot = ParkingLot.arel_table

        condition = like(parking_lot[:name]).or(
          like(Location.arel_table[:full_address])
        )

        condition
      end
    end
  end
end
