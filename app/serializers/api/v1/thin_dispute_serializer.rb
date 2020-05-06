module Api
  module V1
    class ThinDisputeSerializer < ApplicationSerializer
      attributes :id, :admin_id, :user_id, :status, :reason
    end
  end
end
