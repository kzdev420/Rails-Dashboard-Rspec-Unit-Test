module Api
  module V1
    class DisputesController < ApplicationController
      # before_action :authenticate_user!

      api :POST, '/api/v1/disputes', 'Create new dispute'
      param :dispute, Hash, required: true do
        param :text, String, required: true
        param :reason, String, required: true
        param :parking_session_id, String, required: true
      end
      header :Authorization, 'Auth token from users#sign_in', required: true

      def create
        payload = params.fetch(:dispute, {}).merge(user_id: current_user.id)
        result = Disputes::Create.run(payload)
        respond_with result, serializer: ThinDisputeSerializer
      end
    end
  end
end
