module Api
  module Dashboard
    class DisputeSerializer < ApplicationSerializer
      attributes :id, :status, :parking_session, :author, :admin

      def parking_session
        session = object.parking_session

        { id: session.id }.tap do |hash|
          [
            :check_in,
            :check_out,
            :created_at,
            :entered_at,
            :exit_at,
            :parked_at,
            :left_at
          ].each_with_object(hash) do |attr, memo|
            memo[attr] = utc(session.send(attr))
          end

          hash[:vehicle] = session.vehicle.as_json(only: [:id, :plate_number])
        end
      end

      def author
        object.user.as_json(only: [:id, :name, :email, :phone])
      end

      def admin
        object.admin.as_json(only: [:id, :name, :username, :email])
      end
    end
  end
end
