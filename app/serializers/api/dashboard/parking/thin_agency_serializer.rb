module Api
  module Dashboard
    module Parking
      class ThinAgencySerializer < ::ApplicationSerializer
        attributes :id, :name, :email, :phone
      end
    end
  end
end
