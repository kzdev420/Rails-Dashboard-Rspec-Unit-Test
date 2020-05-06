module Api
  module V1
    module Ai
      class ApplicationController < ::Api::V1::ApplicationController
        include ::Api::Ai::Logs

        before_action :authenticate_ai!
        before_action :set_parking_lot!

        private

        def authenticate_ai!
          auth_token = request.headers['Authorization']
          return unauthorized! unless auth_token && ::Ai::Token.find_by(value: auth_token)
        end

        def set_parking_lot!
          return parking_lot_not_found! unless parking_lot
        end
      end
    end
  end
end
