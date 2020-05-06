module Api
  module Dashboard
    class CamerasIndexQuery < ApplicationQuery
      def call

        user = options[:user]

        return [] unless options[:parking_lot_id].present?

        scope = user.admin? ? Camera.all : Camera.where(allowed: true)

        parking_lot_id, order, name = options[:parking_lot_id], options[:order], options[:name]

        if parking_lot_id.present?
          scope = scope.where(parking_lot_id: parking_lot_id)
        end

        scope = scope.where('name ilike ?', "%#{name}%") if name.present?

        if order.present?
          keyword, direction = options[:order][:keyword], options[:order][:direction]
          scope = scope.order(Arel.sql("#{keyword} #{direction}")) unless keyword == 'password'
        end

        scope

      end
    end
  end
end
