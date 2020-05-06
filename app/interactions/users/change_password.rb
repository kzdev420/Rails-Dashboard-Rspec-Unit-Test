module Users
  class ChangePassword < ::ApplicationInteraction
    object :user, class: User
    string :password
    string :new_password

    set_callback :execute, :after, :notify_user, if: :valid?

    def execute
      unless user.valid_password?(password)
        errors.add(:password, :invalid)
        return self
      end
      user.update(password: new_password)
      errors.merge!(user.errors) if user.errors.any?
      self
    end

    private

    def notify_user
      user.send_password_change_notification
    end
  end
end
