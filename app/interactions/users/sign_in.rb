module Users
  class SignIn < ApplicationInteraction
    attr_reader :user, :token

    string :email
    string :password

    validate do
      unless @user = User.find_by(email: email)
        errors.add(:email, :invalid)
        throw(:abort)
      end
      unless user.valid_password?(password)
        errors.add(:password, :invalid)
        throw(:abort)
      end
      unless user.confirmed?
        errors.add(:base, :unconfirmed_email)
        throw(:abort)
      end
    end

    def execute
      @token = ::Authorizer.generate_token(user)
      self
    end

    def to_model
      { token: token }
    end
  end
end
