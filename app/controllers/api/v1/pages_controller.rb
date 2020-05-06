module Api
  module V1
    class PagesController < ApplicationController

      api :GET, '/api/dashboard/pages/privacy_policy', 'Get Privacy Policy content'
      header :Authorization, 'Auth token from users#sign_in', required: true

      api :GET, '/api/dashboard/pages/contact_us', 'Get Contact Us content'
      header :Authorization, 'Auth token from users#sign_in', required: true

      def show
        page = params[:id]
        content = I18n.t("pages.#{page}")
        render json: content
      end
    end
  end
end
