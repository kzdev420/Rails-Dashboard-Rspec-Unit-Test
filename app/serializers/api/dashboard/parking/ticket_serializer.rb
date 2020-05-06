module Api
  module Dashboard
    module Parking
      class TicketSerializer < ::ApplicationSerializer
        attributes :id, :type, :lot, :created_at, :status
        belongs_to :admin, key: :officer, serializer: ThinAdminSerializer
        belongs_to :agency, serializer: AgencySerializer

        def type
          object.violation.rule.name
        end

        def lot
          {
            id: object.violation.rule.lot.id,
            name: object.violation.rule.lot.name
          }
        end
      end
    end
  end
end
