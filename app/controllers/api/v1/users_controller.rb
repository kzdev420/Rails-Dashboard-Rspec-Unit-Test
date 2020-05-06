module Api
  module V1
    class UsersController < ::Api::V1::ApplicationController
      # before_action :authenticate_user!, only: [:me, :update_password, :check_password, :update_settings, :push_notification_token, :check_credit_card]

      api :POST, '/api/v1/users/sign_up', 'User registration'
      param :user, Hash do
        param :email, String, required: true
        param :first_name, String, required: true
        param :last_name, String, required: true
        param :avatar, String, 'File or base64', required: false
        param :phone, String, required: true
        param :vehicles, Array do
          param :plate_number, String, required: true
          param :vehicle_type, String, required: false
          param :color, String, required: false
          param :model, String, required: true
          param :manufacturer_id, Integer, required: false
        end
      end

      def sign_up
        result = ::Users::SignUp.run(params[:user] || {})
        respond_with result
      end

      api :POST, '/api/v1/users/sign_in', 'User sign in'
      param :user, Hash do
        param :email, String, required: true
        param :password, String, required: true
      end

      def sign_in
        payload = params.require(:user).permit(:email, :password)
        result = ::Users::SignIn.run(payload)
        respond_with result
      end

      api :POST, '/api/v1/users/send_reset_password_instructions', 'Send reset password instructions'
      param :user, Hash do
        param :email, String, required: true
      end

      def send_reset_password_instructions
        user = User.find_by!(email: params.dig(:user, :email))
        user.send_reset_password_instructions
        render json: {}, status: 200
      end

      api :POST, '/api/v1/users/send_confirmation_instructions', 'Send user confirmation instructions'
      param :user, Hash do
        param :email, String, required: true
      end

      def send_confirmation_instructions
        email = params.dig(:user, :email)
        empty_email! and return if email.blank?
        user = User.find_by(email: email)
        invalid_email! and return if user.nil?
        confirmed_user! and return if user.confirmed_at.present?
        ::Users::SendConfirmation.call(user)
        render json: {}, status: 200
      end

      api :PUT, '/api/v1/users/reset_password', 'Reset user password with token from mail'
      param :user, Hash do
        param :reset_password_token, String, 'Reset password token', required: true
        param :password, String, 'New password', required: true
      end

      def reset_password
        payload = params.require(:user).permit(:password, :reset_password_token).merge(klass: User)
        result = ::Users::ResetPassword.run(payload)
        respond_with result
      end

      api :PUT, '/api/v1/users/confirm', 'Confirm user'
      param :user, Hash do
        param :confirmation_token, String, '6-digits confirmation token', required: true
        param :email, String, 'User email we want to confirm', required: true
      end

      def confirm
        result = ::Users::Confirm.run(params.fetch(:user, {}))
        respond_with result
      end

      api :GET, '/api/v1/users/me', 'Fetch user data'
      header :Authorization, 'Auth token from users#sign_in', required: true

      def me
        respond_with current_user, serializer: UserSerializer
      end

      api :PUT, '/api/v1/users/update_password', 'Update user password'
      param :user, Hash do
        param :password, String, 'Current password', required: true
        param :new_password, String, 'New password', required: true
      end
      header :Authorization, 'Auth token from users#sign_in', required: true

      def update_password
        payload = params.require(:user).permit(:password, :new_password)
        result = ::Users::ChangePassword.run(payload.merge(user: current_user))
        respond_with result
      end

      api :POST, '/api/v1/users/check_password', 'Check current user password'
      param :user, Hash do
        param :password, String, 'Current user password', required: true
      end
      header :Authorization, 'Auth token from users#sign_in', required: true

      def check_password
        result = current_user.valid_password?(params.dig(:user, :password))
        render json: { result: result }
      end

      api :PUT, '/api/v1/users/update_settings', 'Update user profile settings'
      param :user, Hash do
        param :phone, String, required: false
        param :email, String, required: false
        param :first_name, String, required: false
        param :last_name, String, required: false
        param :password, String, 'Current password (for security reasons)', required: true
        param :birthday, Date, required: false
        param :avatar, String, 'File or base64', required: false
        param :delete_avatar, [true, false], 'Indicate if the avatar image should be destroyed', required: false
        param :vehicles_attributes, Array do
          param :plate_number, String, required: true
          param :color, String, required: true
          param :vehicle_type, String, required: true
          param :manufacturer_id, Integer, required: false
          param :model, String, required: true
          param :id, String, required: false
        end
        param :credit_cards_attributes, Array do
          param :number, String, required: true
          param :holder_name, String, required: true
          param :expirtation_month, Integer, required: true
          param :expirtation_year, Integer, required: true
          param :id, Integer, required: false
          param :default, [1, 0], 'Indicate if the credit card should be the default associated to the account', required: true
        end
        param :billing_address, Hash do
          param :address1, String, required: false
          param :city, String, required: false
          param :country_code, String, required: false
          param :state_code, String, "It has to be the full name of the state", required: false
          param :postal_code, String, required: false
        end
        param :shipping_address, Hash do
          param :address1, String, required: false
          param :city, String, required: false
          param :country_code, String, required: false
          param :state_code, String, "It has to be the full name of the state",  required: false
          param :postal_code, String, required: false
          param :shipping_address_same_as_billing, [true, false], required: false
        end
      end
      header :Authorization, 'Auth token from users#sign_in', required: true

      def update_settings
        result = ::Users::UpdateSettings.run(params.fetch(:user, {}).merge(user: current_user))
        respond_with result, serializer: ::Api::V1::UserSerializer
      end

      api :POST, '/api/v1/users/push_notification_token', 'Set push notification token'
      header :Authorization, 'Auth token', required: true
      param :user, Hash do
        param :push_notification_token, String, 'Push Notification token returned by firebase', required: true
      end

      def push_notification_token
        return head(:bad_request) unless params.dig(:user, :push_notification_token)
        id, auth_token = request.headers['Authorization'].split(':')[0], request.headers['Authorization'].split(':')[1]
        user_token = current_user.find_by_token(auth_token)
        user_token.update!(user_push_notification_token: User::PushNotificationToken.create(value: params[:user][:push_notification_token]))
        head :created
      end

      api :POST, '/api/v1/users/check_reset_password_token', 'Reset user password with token from mail'
      param :token, String, 'Reset password token', required: true

      def check_reset_password_token
        user = User.with_reset_password_token(params[:token])
        render json: {
          validToken: user.present? ? user.password_token_valid? : false
        }, status: 200
      end

      api :GET, '/api/v1/users/check_credit_card', 'Check if a credit card is already stored on the suer account'
      header :Authorization, 'Auth token', required: true
      param :number, String, 'Credit card number', required: true

      def check_credit_card
        render json: {
          duplicated: current_user.credit_cards.find_by(number: params[:number]).present?
        }, status: 200
      end

      private

      def current_user
        User.find_by(id: super&.id) # for vehicles eager loading
      end

      def empty_email!
        render json: { error: t('api.errors.empty_email') }, status: 422
      end

      def invalid_email!
        render json: { error: t('api.errors.invalid_email') }, status: 422
      end

    end
  end
end