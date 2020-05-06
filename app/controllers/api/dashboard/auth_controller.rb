module Api
  module Dashboard
    class AuthController < ::Api::Dashboard::ApplicationController
      skip_before_action :authenticate_admin!, only: [:send_reset_password_instructions, :sign_in, :reset_password, :check_reset_password_token]
      wrap_parameters :admin

      api :POST, '/api/dashboard/auth/sign_in', 'Admin sign in'
      param :admin, Hash do
        param :username, String, 'Email or username', required: true
        param :password, String, required: true
      end

      def sign_in
        result = ::Admins::SignIn.run(params.fetch(:admin, {}))
        respond_with result
      end

      api :POST, '/api/dashboard/auth/send_reset_password_instructions', 'Send reset password instructions'
      param :admin, Hash do
        param :username, String, required: true
      end

      def send_reset_password_instructions
        payload = params.fetch(:admin, {})
        result = ::Admins::ResetPasswordMail.run(payload)
        respond_with result
      end

      api :PUT, '/api/dashboard/auth/reset_password', 'Reset admin password with token from mail'
      param :admin, Hash do
        param :reset_password_token, String, 'Reset password token', required: true
        param :password, String, 'New password', required: true
      end

      def reset_password
        payload = params.require(:admin).permit(:password, :reset_password_token).merge(klass: Admin)
        result = ::Users::ResetPassword.run(payload)
        respond_with result
      end

      api :POST, '/api/dashboard/auth/check_reset_password_token', 'Reset admin password with token from mail'
      param :token, String, 'Reset password token', required: true

      def check_reset_password_token
        render json: {
          validToken: Admin.with_reset_password_token(params[:token]).present?
        }, status: 200
      end

      api :POST, '/api/dashboard/auth/push_notification_token', 'Set push notification token'
      header :Authorization, 'Auth token', required: true
      param :admin, Hash do
        param :push_notification_token, String, 'Push Notification token returned by firebase', required: true
      end

      def push_notification_token
        return head(:bad_request) unless params.dig(:admin, :push_notification_token)
        id, auth_token = request.headers['Authorization'].split(':')[0], request.headers['Authorization'].split(':')[1]
        admin_token = current_user.find_by_token(auth_token)
        admin_token.update!(admin_push_notification_token: Admin::PushNotificationToken.create(value: params[:admin][:push_notification_token]))
        head :created
      end

    end
  end
end
