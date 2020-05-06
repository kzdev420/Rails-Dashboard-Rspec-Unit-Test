module Api
  module Dashboard
    class ThinVehicleSerializer < ::ApplicationSerializer
      attributes :id, :plate_number
    end
  end
end
