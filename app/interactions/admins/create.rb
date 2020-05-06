module Admins
  class Create < Base
    attr_reader :password, :user

    string :email
    string :status
    string :username
    string :phone, default: nil # Optional
    integer :role_id
    string :name
    interface :avatar # can be File or String

    def execute
      save_user
      unless user.valid?
        errors.merge!(user.errors)
        return self
      end
      send_mail_to_creator
      send_mail_to_new_user
      self
    end

    private

    def save_user
      @user ||= begin
        @password = SecureRandom.hex(5)
        Admin.create(user_params.merge(password: password))
      end
    end

    def send_mail_to_creator
      AdminMailer.user_created(user, current_user).deliver_later
    end

    def send_mail_to_new_user
      AdminMailer.welcome_letter(user, password).deliver_later
    end
  end
end
