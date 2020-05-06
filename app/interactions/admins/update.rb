module Admins
  class Update < Base

    object :user, class: Admin
    string :email
    string :status
    string :username
    integer :role_id
    string :name
    string :password, default: nil
    string :phone, default: nil
    interface :avatar, default: nil # can be File or String
    boolean :delete_avatar, default: false

    validates :password, length: { minimum: 7, maximum: 50 }, if: :user_tries_to_change_password?

    def execute
      unless user.update(user_params)
        errors.merge!(user.errors)
      else
        user.avatar.purge if delete_avatar
      end
      self
    end

    private

    def user_params
      prms = super
      prms[:password] = password if  user_tries_to_change_password?
      prms
    end

    def user_tries_to_change_password?
      password.present?
    end

  end
end
