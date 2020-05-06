module Api
  module Dashboard
    class CameraSerializer < ApplicationSerializer
      attributes :id, :name, :stream, :login, :password, :created_at, :updated_at, :allowed, :parking_lot, :other_information

      def created_at
        utc(object.created_at)
      end

      def updated_at
        utc(object.updated_at)
      end

      def parking_lot
        object.parking_lot.as_json(only: [:id, :name])
      end
    end
  end
end
