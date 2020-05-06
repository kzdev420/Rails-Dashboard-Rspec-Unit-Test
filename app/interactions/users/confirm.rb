module Users
  class Confirm < ::ApplicationInteraction
    attr_reader :user

    string :confirmation_token
    string :email

    validates :confirmation_token, :email, presence: true

    def execute
      unless @user = User.find_by(email: email)
        errors.add(:email, :invalid)
        return self
      end

      unless user.confirmation_token == confirmation_token
        errors.add(:confirmation_token, :invalid)
        return self
      end

      unless user.confirm
        errors.merge!(user.errors)
      end

      if valid?
        user.update_attributes(confirmation_token: nil, confirmed_at: Time.zone.now)
      end

      self
    end
  end
end
