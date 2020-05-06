module Admins
  class ResetPasswordMail < ::ApplicationInteraction
    attr_reader :admin, :email

    string :username

    validate do
      unless @admin = Admin.find_by(username: username) || Admin.find_by(email: username)
        if username.to_s.include?('@')
          errors.add(:email, :invalid)
        else
          errors.add(:username, :invalid)
        end
        throw(:abort)
      end
    end

    def execute
      admin.send_reset_password_instructions
    end
  end
end
