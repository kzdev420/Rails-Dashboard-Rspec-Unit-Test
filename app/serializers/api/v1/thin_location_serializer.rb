module Api
  module V1
    class ThinLocationSerializer < ::ApplicationSerializer
      attributes :lng, :ltd, :full_address
    end
  end
end
