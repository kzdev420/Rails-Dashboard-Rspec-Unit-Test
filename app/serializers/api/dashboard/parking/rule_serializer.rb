module Api
  module Dashboard
    module Parking
      class Parking::RuleSerializer < ::ApplicationSerializer
        attributes :id,
                   :name,
                   :description,
                   :status,
                   :lot_id,
                   :agency_id
        has_many :admins, key: :recipients, serializer: RecipientSerializer
      end
    end
  end
end
