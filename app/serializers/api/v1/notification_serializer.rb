module Api
  module V1
    class NotificationSerializer < ::ApplicationSerializer
      attributes :id, :title, :text, :read, :created_at, :parking_session_id, :plate_number

      def read
        object.read?
      end

      def created_at
        object.created_at.to_i
      end

      def plate_number
        object.parking_session&.vehicle&.plate_number
      end
    end
  end
end
