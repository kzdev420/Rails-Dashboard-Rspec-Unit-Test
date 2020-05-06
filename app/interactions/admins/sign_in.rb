module Admins
  class SignIn < ::ApplicationInteraction
    attr_reader :admin, :token, :email

    string :username
    string :password

    validate do
      unless @admin = Admin.find_by(username: username.downcase) || Admin.find_by(email: username)
        if username.to_s.include?('@')
          errors.add(:username, :invalid_email)
        else
          errors.add(:username, :invalid_username)
        end
        throw(:abort)
      end
      unless @admin.valid_password?(password)
        errors.add(:password, :invalid)
        throw(:abort)
      end
      unless @admin.active?
        errors.add(:base, :account_not_active)
        throw(:abort)
      end
    end

    def execute
      @token = Authorizer.generate_token(admin)
      self
    end

    def to_model
      { token: token }
    end
  end
end
