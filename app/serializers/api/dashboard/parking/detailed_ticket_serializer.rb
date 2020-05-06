module Api
  module Dashboard
    module Parking
      class DetailedTicketSerializer < TicketSerializer
        attributes :updated_at, :photo_resolution, :updated_trail

        def photo_resolution
          url_for(object.photo_resolution) if object.photo_resolution.attached?
        end

        def updated_trail
          PaperTrail::Logs::Parking::Ticket.new.generate_logs(object)
        end
      end
    end
  end
end
