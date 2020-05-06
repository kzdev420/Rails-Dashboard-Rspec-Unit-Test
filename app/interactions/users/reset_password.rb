module Users
  class ResetPassword < ::ApplicationInteraction
    attr_reader :user

    string :password
    string :reset_password_token
    interface :klass

    set_callback :execute, :after, :send_email, if: :valid?

    def execute
      @user = klass.reset_password_by_token(
        password: password,
        password_confirmation: password,
        reset_password_token: reset_password_token
      )
      errors.merge!(user.errors) if user.errors.any?
      self
    end

    private

    def send_email
      user.send_password_change_notification
    end
  end
end
