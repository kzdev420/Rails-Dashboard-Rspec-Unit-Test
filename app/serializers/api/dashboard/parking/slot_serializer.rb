module Api
  module Dashboard
    module Parking
      class SlotSerializer < ::ApplicationSerializer
        attributes :id,
                   :name,
                   :status,
                   :archived,
                   :active_parking_session,
                   :coordinate_parking_plan

        def active_parking_session
          session = object.parking_sessions.last
          if object.occupied? && session.present?
            SessionSerializer.new(object.parking_sessions.last)
          end
        end
      end
    end
  end
end
