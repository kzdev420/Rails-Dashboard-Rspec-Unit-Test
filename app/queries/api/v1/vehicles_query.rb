module Api
  module V1
    class VehiclesQuery < ::ApplicationQuery
      def call
        plate_number, user_associated = options[:plate_number], options[:user_associated]
        scope = ::Vehicle.all
        scope = scope.where(plate_number: plate_number) if plate_number.present?
        if user_associated.present?
          if user_associated.to_s == '1'
            scope = scope.where.not(user_id: nil)
          else
            scope = scope.where(user_id: nil)
          end
        end
        scope
      end
    end
  end
end
