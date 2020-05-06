module Api
  module V1
    module Ksk
      class ApplicationController < ::Api::V1::ApplicationController
        include ::Api::Ksk::Errors
        include ::Api::Ksk::Logs
        before_action :authenticate_kiosk!

        def current_kiosk
          auth_token = request.headers['Authorization']
          ::Ksk::Token.find_by(value: auth_token).kiosk
        end

        private

        def authenticate_kiosk!
          auth_token = request.headers['Authorization']
          unauthorized! unless auth_token && ::Ksk::Token.find_by(value: auth_token)
        end
      end
    end
  end
end
