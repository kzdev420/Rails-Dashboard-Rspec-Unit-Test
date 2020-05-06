module Api
  module Errors
    extend ActiveSupport::Concern
    included do
      rescue_from ActionController::ParameterMissing, with: :required_param!
      rescue_from ActiveRecord::RecordNotFound, with: :not_found!
      rescue_from ActionController::UnknownFormat, with: :bad_request!
      rescue_from ActionPolicy::Unauthorized, with: :wrong_access!
      rescue_from Payments::StandardError, with: :payment_error!

      def unauthorized!
        render json: { error: t('api.errors.unauthorized') }, status: 401
      end

      def forbidden!
        render json: { error: t('api.errors.forbidden') }, status: 403
      end

      def not_found!
        render json: { error: t('api.errors.not_found') }, status: 404
      end

      def bad_request!
        render json: { error: t('api.errors.bad_request') }, status: 400
      end

      def unconfirmed_user!
        render json: { error: t('api.errors.unconfirmed_user') }, status: 403
      end

      def confirmed_user!
        render json: { error: t('api.errors.confirmed_user') }, status: 422
      end

      def parking_lot_not_found!
        render json: { error: t('api.errors.parking_lot_not_found') }, status: 404
      end

      def role_not_found!
        render json: { errors: { "role_id": [t("api.errors.role_not_found" )] } }, status: 422
      end

      def wrong_access!
        render json: { error: t('api.errors.wrong_access') }, status: 403
      end

      def required_param!(exception)
        error_message = (t('api.errors.param_is_required') % { attribute: exception.param })&.capitalize
        render json: { errors: { exception.param => error_message } }, status: 422
      end

      def account_suspended!
        render json: { error: t('api.errors.account_suspended') }, status: 405
      end

      def payment_error!(exception)
        render json: { error: exception.message }, status: 422
      end

    end
  end
end
